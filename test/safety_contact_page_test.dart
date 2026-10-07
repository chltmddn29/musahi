import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/features/setting/model/safety_contact_model.dart';
import 'package:musahi/features/setting/model/safety_contact_store.dart';
import 'package:musahi/features/setting/presentation/setting_detail/safety_contact_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _contacts = [
  SafetyContact(id: '1', name: '김민수', phone: '010-1234-5678', relation: '가족'),
  SafetyContact(
    id: '2',
    name: '박서준영희철수',
    phone: '010-9876-5432',
    relation: '기타',
  ),
];

Future<void> _pumpContacts(
  WidgetTester tester, {
  double textScale = 1,
  Size size = const Size(360, 640),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: '/setting/contacts',
    routes: [
      GoRoute(
        path: '/setting/contacts',
        builder: (_, _) => const SafetyContactPage(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (_, _) => const Scaffold(body: Text('연락처 추가 화면')),
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
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SafetyContactStore.instance.contacts.value = _contacts;
  });

  tearDown(() => SafetyContactStore.instance.contacts.value = []);

  testWidgets('contact rows fit a narrow screen without overflowing', (
    tester,
  ) async {
    await _pumpContacts(tester, size: const Size(320, 640));

    expect(tester.takeException(), isNull);
    // 오버플로우가 잘려서 통과하는 게 아니라 실제로 다 보이는지 확인한다.
    for (final contact in _contacts) {
      expect(find.text(contact.name), findsOneWidget);
      expect(
        find.text('${contact.relation} · ${contact.phone}'),
        findsOneWidget,
      );
    }
  });

  testWidgets('contact rows survive large text scaling', (tester) async {
    await _pumpContacts(tester, textScale: 2);

    expect(tester.takeException(), isNull);
    expect(find.text(_contacts.last.name), findsOneWidget);
  });

  testWidgets('edit stays tappable on a narrow screen', (tester) async {
    await _pumpContacts(tester, size: const Size(320, 640));

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('연락처 추가 화면'), findsOneWidget);
  });

  testWidgets('delete stays tappable on a narrow screen', (tester) async {
    await _pumpContacts(tester, size: const Size(320, 640));

    await tester.tap(find.byIcon(Icons.close).last);
    await tester.pumpAndSettle();
    expect(find.text(_contacts.last.name), findsNothing);
    expect(find.text(_contacts.first.name), findsOneWidget);
  });
}
