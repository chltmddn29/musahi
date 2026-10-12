import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/features/setting/model/safety_contact_model.dart';
import 'package:musahi/features/setting/model/safety_contact_store.dart';
import 'package:musahi/features/share/share_complete_page.dart';
import 'package:musahi/features/share/share_page.dart';
import 'package:musahi/features/share/widgets/share_message_editor.dart';

const _shareLabel = '저는 안전합니다 (공유하기)';
const _defaultMessage = '저는 지금 안전합니다. 걱정하지 마세요.';

final _contacts = [
  SafetyContact(id: '1', name: '김민수', phone: '010-1234-5678', relation: '가족'),
  SafetyContact(id: '2', name: '이영희', phone: '010-9876-5432', relation: '지인'),
];

Future<GoRouter> _pumpShare(
  WidgetTester tester, {
  double textScale = 1,
}) async {
  final rootKey = GlobalKey<NavigatorState>();
  final router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/share',
    routes: [
      ShellRoute(
        builder: (_, _, child) => Scaffold(
          body: child,
          bottomNavigationBar: const Text('하단 탭'),
        ),
        routes: [
          GoRoute(
            path: '/share',
            builder: (_, _) => const SharePage(),
            routes: [
              GoRoute(
                path: 'complete',
                parentNavigatorKey: rootKey,
                builder: (_, state) => ShareCompletePage(
                  preview: state.extra as SafetySharePreview?,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/info',
        builder: (_, _) => const Scaffold(body: Text('홈 화면')),
      ),
      GoRoute(
        path: '/setting/contacts/add',
        builder: (_, _) => const Scaffold(body: Text('연락처 추가 화면')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  setUp(() {
    SafetyContactStore.instance.contacts.value = List.of(_contacts);
  });

  tearDown(() {
    SafetyContactStore.instance.contacts.value = [];
  });

  testWidgets('registered contacts update without recreating the page', (
    tester,
  ) async {
    await _pumpShare(tester);

    expect(find.text('안전 상태 공유'), findsOneWidget);
    expect(find.text('김민수'), findsOneWidget);
    expect(find.text('이영희'), findsOneWidget);
    expect(find.text('가족'), findsOneWidget);
    expect(find.text(_defaultMessage), findsOneWidget);

    SafetyContactStore.instance.contacts.value = [_contacts.last];
    await tester.pump();

    expect(find.text('김민수'), findsNothing);
    expect(find.text('이영희'), findsOneWidget);
  });

  testWidgets('empty contacts disable sharing and link to contact creation', (
    tester,
  ) async {
    SafetyContactStore.instance.contacts.value = [];
    await _pumpShare(tester);

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, _shareLabel),
    );
    expect(button.onPressed, isNull);

    await tester.tap(find.text('등록된 안전 연락처가 없습니다'));
    await tester.pumpAndSettle();
    expect(find.text('연락처 추가 화면'), findsOneWidget);
  });

  testWidgets('message editor validates, trims, saves and discards drafts', (
    tester,
  ) async {
    await _pumpShare(tester);
    await tester.tap(find.byTooltip('메시지 수정'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.text('공유할 메시지를 입력해 주세요.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '  안전한 곳에 도착했어요.  ');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.text('안전한 곳에 도착했어요.'), findsOneWidget);
    expect(find.byType(ShareMessageEditor), findsNothing);

    await tester.tap(find.byTooltip('메시지 수정'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '저장하지 않은 메시지');
    Navigator.of(tester.element(find.byType(ShareMessageEditor))).pop();
    await tester.pumpAndSettle();
    expect(find.text('안전한 곳에 도착했어요.'), findsOneWidget);
    expect(find.text('저장하지 않은 메시지'), findsNothing);
  });

  testWidgets('preview hides tabs, prevents duplicate pushes and returns home', (
    tester,
  ) async {
    final router = await _pumpShare(tester);
    await tester.tap(find.text(_shareLabel));
    await tester.tap(find.text(_shareLabel));
    await tester.pumpAndSettle();

    expect(find.byType(ShareCompletePage), findsOneWidget);
    expect(find.text('전송 완료'), findsOneWidget);
    expect(find.textContaining('실제 메시지는 전송되지 않았습니다.'), findsOneWidget);
    expect(find.textContaining('김민수, 이영희'), findsOneWidget);
    expect(find.textContaining('오늘 '), findsOneWidget);
    expect(find.text('하단 탭'), findsNothing);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(ShareCompletePage), findsNothing);
    expect(find.text('하단 탭'), findsOneWidget);

    await tester.tap(find.text(_shareLabel));
    await tester.pumpAndSettle();
    await tester.tap(find.text('홈으로 돌아가기'));
    await tester.pumpAndSettle();
    expect(find.text('홈 화면'), findsOneWidget);
  });

  testWidgets('direct completion navigation does not claim a successful send', (
    tester,
  ) async {
    final router = await _pumpShare(tester);
    router.go('/share/complete');
    await tester.pumpAndSettle();
    expect(find.text('공유 정보가 없습니다.'), findsOneWidget);
    expect(find.text('전송 완료'), findsNothing);
    expect(find.text('홈으로 돌아가기'), findsOneWidget);
  });

  testWidgets('long contacts and large text scroll without overflowing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SafetyContactStore.instance.contacts.value = List.generate(
      12,
      (index) => SafetyContact(
        id: '$index',
        name: '아주 긴 이름의 안전 연락처 $index',
        phone: '010-1234-5678',
        relation: '가족',
      ),
    );
    await _pumpShare(tester, textScale: 2);
    expect(tester.takeException(), isNull);
    expect(find.text(_shareLabel).hitTestable(), findsOneWidget);

    await tester.tap(find.text(_shareLabel));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('홈으로 돌아가기'));
    await tester.tap(find.text('홈으로 돌아가기'));
    await tester.pumpAndSettle();
    expect(find.text('홈 화면'), findsOneWidget);
  });

  test('preview captures an immutable contact snapshot', () {
    final names = ['김민수'];
    final preview = SafetySharePreview(
      contactNames: names,
      createdAt: DateTime(2026, 9, 18, 14, 35),
    );
    names.clear();
    expect(preview.contactNames, ['김민수']);
    expect(() => preview.contactNames.add('이영희'), throwsUnsupportedError);
  });
}
