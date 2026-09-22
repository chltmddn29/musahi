import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/settings/notification_settings.dart';
import 'package:musahi/features/setting/model/region_model.dart';
import 'package:musahi/features/setting/model/region_store.dart';
import 'package:musahi/features/setting/model/safety_contact_model.dart';
import 'package:musahi/features/setting/model/safety_contact_store.dart';
import 'package:musahi/features/setting/presentation/setting_page.dart';
import 'package:musahi/features/setting/widget/setting_menu_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _navTitles = ['언어 설정', '관심지역 관리', '안전 연락처 관리', '텍스트 크기 조절'];
const _switchTitles = ['재난문자 알림', '안전 안내 알림'];

Future<GoRouter> _pumpSettings(
  WidgetTester tester, {
  double textScale = 1,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: '/setting',
    routes: [
      GoRoute(
        path: '/setting',
        builder: (_, _) => const SettingPage(),
        routes: [
          for (final path in ['language', 'region', 'contacts', 'text-size'])
            GoRoute(
              path: path,
              builder: (_, _) => Scaffold(body: Text('$path 화면')),
            ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Finder _tileOf(String title) =>
    find.ancestor(of: find.text(title), matching: find.byType(SettingMenuTile));

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SafetyContactStore.instance.contacts.value = [
      SafetyContact(
        id: '1',
        name: '김민수',
        phone: '010-1234-5678',
        relation: '가족',
      ),
    ];
    InterestRegionStore.instance.regions.value = [];
    InterestRegionStore.instance.primaryCd.value = null;
  });

  tearDown(() {
    SafetyContactStore.instance.contacts.value = [];
    InterestRegionStore.instance.regions.value = [];
  });

  testWidgets('switches and chevrons share one right edge', (tester) async {
    await _pumpSettings(tester);

    final rightEdges = <double>{};
    for (final title in _switchTitles) {
      rightEdges.add(
        tester
            .getRect(
              find.descendant(
                of: _tileOf(title),
                matching: find.byType(CupertinoSwitch),
              ),
            )
            .right,
      );
    }
    for (final title in _navTitles) {
      rightEdges.add(
        tester
            .getRect(
              find.descendant(
                of: _tileOf(title),
                matching: find.byIcon(Icons.arrow_forward_ios),
              ),
            )
            .right,
      );
    }

    expect(
      rightEdges,
      hasLength(1),
      reason: '스위치·화살표가 서로 다른 x에 놓이면 안 된다: $rightEdges',
    );
  });

  testWidgets('every row shares one height and one left edge', (tester) async {
    await _pumpSettings(tester);

    final heights = <double>{};
    final leftEdges = <double>{};
    for (final title in [..._switchTitles, ..._navTitles]) {
      heights.add(tester.getRect(_tileOf(title)).height);
      leftEdges.add(tester.getRect(find.text(title)).left);
    }

    expect(heights, hasLength(1), reason: '행 높이가 제각각이면 안 된다: $heights');
    expect(leftEdges, hasLength(1), reason: '제목 시작점이 어긋나면 안 된다: $leftEdges');
  });

  testWidgets('tapping anywhere on a row navigates', (tester) async {
    final router = await _pumpSettings(tester);

    // 화살표가 아니라 제목을 눌러도 이동해야 한다.
    await tester.tap(find.text('안전 연락처 관리'));
    await tester.pumpAndSettle();
    expect(find.text('contacts 화면'), findsOneWidget);
    expect(router.state.uri.path, '/setting/contacts');
  });

  testWidgets('switch rows toggle without navigating', (tester) async {
    await _pumpSettings(tester);
    final before = disasterAlertEnabled.value;

    await tester.tap(
      find.descendant(
        of: _tileOf('재난문자 알림'),
        matching: find.byType(CupertinoSwitch),
      ),
    );
    await tester.pumpAndSettle();

    expect(disasterAlertEnabled.value, !before);
  });

  testWidgets('long subtitles and large text do not overflow', (tester) async {
    InterestRegionStore.instance.regions.value = [
      RegionItem(
        addrName: '서울특별시 강남구 역삼1동',
        cd: '1168010100',
        fullAddr: '서울특별시 강남구 역삼1동',
        yCoor: '',
        xCoor: '',
      ),
      RegionItem(
        addrName: '부산광역시 해운대구',
        cd: '2635010100',
        fullAddr: '부산광역시 해운대구',
        yCoor: '',
        xCoor: '',
      ),
    ];

    await _pumpSettings(tester, textScale: 2, size: const Size(320, 844));

    expect(tester.takeException(), isNull);
    for (final title in [..._switchTitles, ..._navTitles]) {
      expect(find.text(title), findsOneWidget);
    }
  });
}
