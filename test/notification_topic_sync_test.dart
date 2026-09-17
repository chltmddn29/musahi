import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/core/notifications/notification_topic_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('switches independently select server severity topics', () {
    for (final disaster in [false, true]) {
      for (final safety in [false, true]) {
        expect(
          NotificationTopicSync.topicsFor(
            regionCodes: ['236', '237', '236'],
            disasterEnabled: disaster,
            safetyEnabled: safety,
          ),
          {
            if (disaster) ...['region_236_critical', 'region_237_critical'],
            if (safety) ...['region_236_safe', 'region_237_safe'],
          },
        );
      }
    }
    expect(
      NotificationTopicSync.topicsFor(
        regionCodes: [],
        disasterEnabled: true,
        safetyEnabled: true,
      ),
      isEmpty,
    );
  });

  test(
    'removes global and stale topics and persists the current set',
    () async {
      SharedPreferences.setMockInitialValues({
        NotificationTopicSync.storageKey: ['region_237_safe'],
      });
      final calls = <String>[];
      final sync = NotificationTopicSync(
        subscribe: (topic) async => calls.add('add:$topic'),
        unsubscribe: (topic) async => calls.add('remove:$topic'),
      );
      await sync.sync(
        {'region_236_critical'},
        legacyTopics: {'region_all', 'region_11_critical', 'region_11_safe'},
      );
      expect(calls, [
        'remove:region_237_safe',
        'remove:region_all',
        'remove:region_11_critical',
        'remove:region_11_safe',
        'add:region_236_critical',
      ]);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(NotificationTopicSync.storageKey), [
        'region_236_critical',
      ]);
      await sync.sync({});
      expect(calls.last, 'remove:region_236_critical');
      expect(prefs.getStringList(NotificationTopicSync.storageKey), isEmpty);
    },
  );

  test('serializes rapid changes so the last preference wins', () async {
    final gate = Completer<void>();
    final started = Completer<void>();
    final subscribed = <String>{};
    final sync = NotificationTopicSync(
      subscribe: (topic) async {
        started.complete();
        await gate.future;
        subscribed.add(topic);
      },
      unsubscribe: (topic) async => subscribed.remove(topic),
    );
    final enable = sync.sync({'region_236_critical'});
    await started.future;
    final disable = sync.sync({});
    gate.complete();
    await Future.wait([enable, disable]);
    expect(subscribed, isEmpty);
  });

  test('failed subscriptions stay tracked for cleanup after restart', () async {
    final sync = NotificationTopicSync(
      subscribe: (_) async => throw PlatformException(code: 'offline'),
      unsubscribe: (_) async {},
    );
    await expectLater(
      sync.sync({'region_236_safe'}),
      throwsA(isA<PlatformException>()),
    );
    final removed = <String>[];
    final restarted = NotificationTopicSync(
      subscribe: (_) async {},
      unsubscribe: (topic) async => removed.add(topic),
    );
    await restarted.sync({});
    expect(removed, ['region_236_safe']);
  });

  test('failed unsubscribe is retried and does not poison the queue', () async {
    SharedPreferences.setMockInitialValues({
      NotificationTopicSync.storageKey: ['region_236_safe'],
    });
    var offline = true;
    final sync = NotificationTopicSync(
      subscribe: (_) async {},
      unsubscribe: (_) async {
        if (offline) throw PlatformException(code: 'offline');
      },
    );
    await expectLater(sync.sync({}), throwsA(isA<PlatformException>()));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(NotificationTopicSync.storageKey), [
      'region_236_safe',
    ]);
    offline = false;
    await sync.sync({});
    expect(prefs.getStringList(NotificationTopicSync.storageKey), isEmpty);
  });

  test('reapplies subscriptions after token refresh', () async {
    final added = <String>[];
    final sync = NotificationTopicSync(
      subscribe: (topic) async => added.add(topic),
      unsubscribe: (_) async {},
    );
    await sync.sync({'region_236_critical'});
    await sync.sync({'region_236_critical'});
    expect(added, ['region_236_critical', 'region_236_critical']);
  });
}
