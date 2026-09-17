import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:musahi/core/notifications/notification_topic_sync.dart';
import 'package:musahi/core/settings/notification_settings.dart';
import 'package:musahi/features/setting/model/region_store.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  const NotificationService._();

  static final syncError = ValueNotifier<String?>(null);
  static final _topicSync = NotificationTopicSync(
    subscribe: (topic) => FirebaseMessaging.instance.subscribeToTopic(topic),
    unsubscribe: (topic) =>
        FirebaseMessaging.instance.unsubscribeFromTopic(topic),
  );
  static bool _listening = false;
  static bool _ready = false;
  static Future<void>? _initialization;
  static AppLifecycleListener? _lifecycleListener;

  static Future<void> init() {
    return _initialization ??= _initialize().whenComplete(() {
      _initialization = null;
    });
  }

  static Future<void> _initialize() async {
    if (!_listening) {
      _listening = true;
      disasterAlertEnabled.addListener(synchronizeSubscriptions);
      safetyGuideAlertEnabled.addListener(synchronizeSubscriptions);
      InterestRegionStore.instance.regions.addListener(
        synchronizeSubscriptions,
      );
      FirebaseMessaging.onMessage.listen(_handleMessage);
      FirebaseMessaging.instance.onTokenRefresh.listen(
        (_) => synchronizeSubscriptions(),
        onError: (Object error, StackTrace stack) => _reportFailure(error),
      );
      _lifecycleListener ??= AppLifecycleListener(
        onResume: synchronizeSubscriptions,
      );
    }
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      debugPrint('알림 권한 상태: ${settings.authorizationStatus}');

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await _waitForApnsToken();
      }

      _ready = true;
      await synchronizeSubscriptions();
    } on FirebaseException catch (error) {
      _reportFailure(error);
    } on PlatformException catch (error) {
      _reportFailure(error);
    } on TimeoutException catch (error) {
      _reportFailure(error);
    }
  }

  static Future<void> synchronizeSubscriptions() async {
    if (!_ready) {
      await init();
      return;
    }
    final regions = InterestRegionStore.instance.regions.value;
    final topics = NotificationTopicSync.topicsFor(
      regionCodes: regions.map((r) => r.notificationCode).nonNulls,
      disasterEnabled: disasterAlertEnabled.value,
      safetyEnabled: safetyGuideAlertEnabled.value,
    );
    try {
      await _topicSync.sync(
        topics,
        legacyTopics: {
          'region_all',
          'region_236_critical',
          'region_236_safe',
          for (final region in regions)
            if (region.notificationCode == null) ...[
              'region_${region.cd}_critical',
              'region_${region.cd}_safe',
            ],
        },
      );
      syncError.value = null;
      debugPrint(
        '알림 설정 동기화 완료: 재난문자=${disasterAlertEnabled.value}, '
        '안전안내=${safetyGuideAlertEnabled.value}, '
        '구독 토픽=${topics.isEmpty ? '없음' : topics.join(', ')}',
      );
    } on FirebaseException catch (error) {
      _reportFailure(error);
    } on PlatformException catch (error) {
      _reportFailure(error);
    }
  }

  static void _reportFailure(Object error) {
    debugPrint('알림 설정 동기화 실패: $error');
    syncError.value = '알림 설정을 서버에 반영하지 못했습니다. 연결 후 다시 시도해주세요.';
  }

  /// iOS 실기기에서는 보통 곧바로 발급되지만, 시뮬레이터는 APNS를 지원하지
  /// 않아 [FirebaseMessaging.getAPNSToken]이 계속 null이거나 예외를 던진다.
  static Future<void> _waitForApnsToken() async {
    for (var retries = 0; retries < 10; retries++) {
      if (await FirebaseMessaging.instance.getAPNSToken() != null) return;
      await Future.delayed(const Duration(seconds: 1));
    }
    throw TimeoutException('APNS 토큰을 받지 못했습니다.');
  }

  static void _handleMessage(RemoteMessage message) {
    final severity = message.data['severity'] ?? '안전안내';
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';

    // '위급'/'긴급'은 재난문자 알림, 그 외(안전안내)는 안전 안내 알림 설정을 따른다.
    final isDisasterAlert = severity == '위급' || severity == '긴급';
    if (isDisasterAlert && !disasterAlertEnabled.value) return;
    if (!isDisasterAlert && !safetyGuideAlertEnabled.value) return;

    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    if (severity == '위급') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Colors.red.shade700,
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(body, style: const TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    } else if (severity == '긴급') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange.shade800,
          duration: const Duration(seconds: 8),
          content: Text(
            '$title\n$body',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.blueGrey,
          duration: const Duration(seconds: 5),
          content: Text(
            '$title\n$body',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }
}
