import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:musahi/core/settings/notification_settings.dart';
import 'package:musahi/features/setting/model/region_store.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  const NotificationService._();

  static Future<void> init() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      debugPrint('알림 권한 상태: ${settings.authorizationStatus}');

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        await _waitForApnsToken();
      }

      await FirebaseMessaging.instance.subscribeToTopic('region_all');
      for (final region in InterestRegionStore.instance.regions.value) {
        await subscribeToRegion(region.cd);
      }

      FirebaseMessaging.onMessage.listen(_handleMessage);
    } catch (e) {
      // 웹은 dart:io Platform을 지원하지 않고, 시뮬레이터 등은 APNS 토큰이
      // 끝내 발급되지 않을 수 있다 — 알림 초기화 실패가 앱 구동 자체를
      // 막지 않도록 여기서 흡수한다.
      debugPrint('알림 초기화 실패: $e');
    }
  }

  /// 관심지역 추가 시 호출해 해당 지역의 재난문자 토픽을 구독한다.
  static Future<void> subscribeToRegion(String cd) async {
    await FirebaseMessaging.instance.subscribeToTopic('region_${cd}_critical');
    await FirebaseMessaging.instance.subscribeToTopic('region_${cd}_safe');
  }

  /// 관심지역 삭제 시 호출해 해당 지역의 재난문자 토픽 구독을 해제한다.
  static Future<void> unsubscribeFromRegion(String cd) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(
      'region_${cd}_critical',
    );
    await FirebaseMessaging.instance.unsubscribeFromTopic('region_${cd}_safe');
  }

  /// iOS 실기기에서는 보통 곧바로 발급되지만, 시뮬레이터는 APNS를 지원하지
  /// 않아 [FirebaseMessaging.getAPNSToken]이 계속 null이거나 예외를 던진다.
  static Future<void> _waitForApnsToken() async {
    for (var retries = 0; retries < 10; retries++) {
      try {
        if (await FirebaseMessaging.instance.getAPNSToken() != null) return;
      } catch (_) {
        return;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
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
