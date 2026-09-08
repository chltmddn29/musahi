import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  const NotificationService._();

  static Future<void> init() async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    debugPrint('알림 권한 상태: ${settings.authorizationStatus}');

    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      int retries = 0;
      while (apnsToken == null && retries < 10) {
        await Future.delayed(const Duration(seconds: 1));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        retries++;
      }
    }

    await FirebaseMessaging.instance.subscribeToTopic('region_all');
    await FirebaseMessaging.instance.subscribeToTopic('region_236_critical');
    await FirebaseMessaging.instance.subscribeToTopic('region_236_safe');

    FirebaseMessaging.onMessage.listen(_handleMessage);
  }

  static void _handleMessage(RemoteMessage message) {
    final severity = message.data['severity'] ?? '안전안내';
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';

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
