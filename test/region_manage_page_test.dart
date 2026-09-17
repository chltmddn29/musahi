import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/features/setting/model/region_model.dart';
import 'package:musahi/features/setting/model/region_store.dart';
import 'package:musahi/features/setting/presentation/setting_detail/region_manage_page.dart';
import 'package:musahi/features/setting/repository/region_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Repository extends RegionRepository {
  _Repository({required this.fetch, required this.fetchNotifications});

  final Future<List<RegionItem>> Function(String? cd) fetch;
  final Future<List<RegionItem>> Function() fetchNotifications;

  @override
  Future<List<RegionItem>> fetchRegions({String? cd}) => fetch(cd);

  @override
  Future<List<RegionItem>> fetchNotificationRegions() => fetchNotifications();
}

void main() {
  final region = RegionItem.fromDisasterRegion({
    'code': '236',
    'name': 'Seoul',
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    InterestRegionStore.instance.regions.value = [];
    InterestRegionStore.instance.primaryCd.value = null;
  });

  test('keeps disaster codes distinct from legacy SGIS regions', () async {
    expect(RegionItem.fromJson(region.toJson()).notificationCode, '236');
    final legacy = RegionItem.fromJson({'cd': '236', 'addr_name': 'Legacy'});
    expect(legacy.notificationCode, isNull);
    InterestRegionStore.instance.add(legacy);
    InterestRegionStore.instance.add(region);
    expect(InterestRegionStore.instance.regions.value.single, region);
    await pumpEventQueue();
    await InterestRegionStore.instance.load();
    expect(
      InterestRegionStore.instance.regions.value.single.notificationCode,
      '236',
    );
  });

  test('migrates only uniquely matching legacy full addresses', () async {
    final matchingLegacy = RegionItem(
      addrName: 'Gangnam',
      cd: '1168010100',
      fullAddr: 'Seoul Gangnam',
      yCoor: '',
      xCoor: '',
    );
    final unmatchedLegacy = RegionItem(
      addrName: 'Gangnam',
      cd: '999',
      fullAddr: 'Other Gangnam',
      yCoor: '',
      xCoor: '',
    );
    final duplicateLegacy = RegionItem(
      addrName: 'Duplicate',
      cd: '998',
      fullAddr: 'Duplicate',
      yCoor: '',
      xCoor: '',
    );
    InterestRegionStore.instance.regions.value = [
      matchingLegacy,
      unmatchedLegacy,
      duplicateLegacy,
    ];
    InterestRegionStore.instance.primaryCd.value = matchingLegacy.cd;

    await InterestRegionStore.instance.migrateLegacyRegions([
      RegionItem.fromDisasterRegion({'code': '236', 'name': 'Seoul Gangnam'}),
      RegionItem.fromDisasterRegion({'code': '237', 'name': 'Duplicate'}),
      RegionItem.fromDisasterRegion({'code': '238', 'name': 'Duplicate'}),
    ]);

    expect(
      InterestRegionStore.instance.regions.value[0].notificationCode,
      '236',
    );
    expect(
      InterestRegionStore.instance.regions.value[1].notificationCode,
      isNull,
    );
    expect(
      InterestRegionStore.instance.regions.value[2].notificationCode,
      isNull,
    );
    expect(InterestRegionStore.instance.primaryCd.value, '236');
  });

  test('rejects malformed server regions rather than subscribing', () {
    expect(
      () => RegionItem.fromDisasterRegion({'code': '', 'name': 'Seoul'}),
      throwsFormatException,
    );
    expect(
      () => RegionItem.fromDisasterRegion({'code': '236'}),
      throwsFormatException,
    );
  });

  test('maps a selected dong to the closest matching notification area', () {
    final seoul = RegionItem(
      addrName: '서울특별시',
      cd: '11',
      fullAddr: '',
      yCoor: '',
      xCoor: '',
    );
    final gangnam = RegionItem(
      addrName: '강남구',
      cd: '11680',
      fullAddr: '',
      yCoor: '',
      xCoor: '',
    );
    final yeoksam = RegionItem(
      addrName: '역삼동',
      cd: '11680101',
      fullAddr: '',
      yCoor: '',
      xCoor: '',
    );
    expect(
      resolveNotificationCode(
        [seoul, gangnam, yeoksam],
        [
          RegionItem.fromDisasterRegion({'code': '136', 'name': '서울특별시'}),
          RegionItem.fromDisasterRegion({'code': '137', 'name': '서울특별시 강남구'}),
        ],
      ),
      '137',
    );
    expect(resolveNotificationCode([seoul], []), isNull);
  });

  testWidgets('searches SGIS, adds and removes mapped regions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegionManagePage(
          repository: _Repository(
            fetch: (_) async => [
              RegionItem(
                addrName: 'Seoul',
                cd: '11',
                fullAddr: '',
                yCoor: '',
                xCoor: '',
              ),
            ],
            fetchNotifications: () async => [region],
          ),
        ),
      ),
    );
    await tester.tap(find.text('관심지역 추가'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pump();
    expect(find.text('검색 결과가 없습니다'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Seoul');
    await tester.pump();
    await tester.tap(find.text('선택'));
    await tester.pump();
    await tester.tap(find.text('추가'));
    await tester.pumpAndSettle();
    expect(
      InterestRegionStore.instance.regions.value.single.notificationCode,
      '236',
    );
    await tester.tap(find.byTooltip('Seoul 삭제'));
    await tester.pumpAndSettle();
    expect(InterestRegionStore.instance.regions.value, isEmpty);
  });

  testWidgets('shows legacy region reselection instructions', (tester) async {
    InterestRegionStore.instance.add(
      RegionItem.fromJson({'cd': '11', 'addr_name': 'Seoul'}),
    );
    await tester.pumpWidget(const MaterialApp(home: RegionManagePage()));
    expect(find.textContaining('삭제 후 다시 추가'), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('shows load errors and allows retry', (tester) async {
    var fail = true;
    await tester.pumpWidget(
      MaterialApp(
        home: RegionManagePage(
          repository: _Repository(
            fetch: (_) async {
              if (fail) {
                throw FirebaseException(
                  plugin: 'cloud_firestore',
                  code: 'denied',
                );
              }
              return [];
            },
            fetchNotifications: () async => [],
          ),
        ),
      ),
    );
    await tester.tap(find.text('관심지역 추가'));
    await tester.pumpAndSettle();
    expect(find.text('지역 정보를 불러오지 못했습니다'), findsOneWidget);
    fail = false;
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.text('하위 지역이 없습니다'), findsOneWidget);
  });

  testWidgets('ignores results after leaving the page', (tester) async {
    final response = Completer<List<RegionItem>>();
    await tester.pumpWidget(
      MaterialApp(
        home: RegionManagePage(
          repository: _Repository(
            fetch: (_) => response.future,
            fetchNotifications: () async => [],
          ),
        ),
      ),
    );
    await tester.tap(find.text('관심지역 추가'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    response.complete([region]);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
