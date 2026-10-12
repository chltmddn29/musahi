import 'dart:async';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationTopicSync {
  NotificationTopicSync({required this.subscribe, required this.unsubscribe});

  final Future<void> Function(String topic) subscribe;
  final Future<void> Function(String topic) unsubscribe;
  Future<void> _pending = Future.value();

  static const storageKey = 'notification_topics';

  static Set<String> topicsFor({
    required Iterable<String> regionCodes,
    required bool disasterEnabled,
    required bool safetyEnabled,
  }) => {
    for (final code in regionCodes) ...[
      if (disasterEnabled) 'region_${code}_critical',
      if (safetyEnabled) 'region_${code}_safe',
    ],
  };

  Future<void> sync(
    Set<String> desired, {
    Set<String> legacyTopics = const {},
  }) async {
    final previous = _pending;
    final completed = Completer<void>();
    _pending = completed.future;
    try {
      await previous;
      final prefs = await SharedPreferences.getInstance();
      final known = {...?prefs.getStringList(storageKey), ...legacyTopics};

      Future<void> save() async {
        if (!await prefs.setStringList(storageKey, known.toList())) {
          throw PlatformException(code: 'notification-topic-storage-failed');
        }
      }

      // Persist intent before FCM calls so interrupted/failed changes can be
      // reconciled on the next attempt, including after an app restart.
      await save();
      for (final topic in known.difference(desired)) {
        await unsubscribe(topic);
        known.remove(topic);
        await save();
      }
      for (final topic in desired) {
        known.add(topic);
        await save();
        // Reapply even known topics: FCM may have issued a new device token.
        await subscribe(topic);
      }
    } finally {
      // Release the queue without hiding the error from this call's caller.
      completed.complete();
    }
  }
}
