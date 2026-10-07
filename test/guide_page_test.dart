import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/features/guide/presentation/guide_detail_page.dart';
import 'package:musahi/features/guide/presentation/guide_page.dart';
import 'package:musahi/features/guide/model/disaster_guide.dart';

void main() {
  testWidgets('탭에서 유형을 바꾸면 해당 행동요령을 보여준다', (tester) async {
    final router = GoRouter(
      initialLocation: '/guide',
      routes: [
        GoRoute(path: '/guide', builder: (_, _) => const GuidePage()),
        GoRoute(path: '/shelter', builder: (_, _) => const Text('대피소 탭')),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('지진 행동요령'), findsOneWidget);
    expect(find.text(DisasterGuide.earthquake.steps.first.title), findsOneWidget);
    expect(find.text('가까운 대피소 보기'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, '호우'));
    await tester.pumpAndSettle();
    expect(find.text('호우 행동요령'), findsOneWidget);
    expect(find.text(DisasterGuide.heavyRain.steps.first.title), findsOneWidget);

    await tester.tap(find.text('가까운 대피소 보기'));
    await tester.pumpAndSettle();
    expect(find.text('대피소 탭'), findsOneWidget);
  });

  testWidgets('폭염은 대피소 버튼을 숨긴다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GuidePage()));

    await tester.tap(find.widgetWithText(ElevatedButton, '폭염'));
    await tester.pumpAndSettle();

    expect(find.text('폭염 행동요령'), findsOneWidget);
    expect(find.text('가까운 대피소 보기'), findsNothing);
  });

  testWidgets('상세는 뒤로가기가 있고 재난 지역 대피소로 이동한다', (tester) async {
    String? openedRegion;
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Text('재난문자 상세'),
          routes: [
            GoRoute(
              path: 'guide',
              builder: (_, _) => const GuideDetailPage(
                guide: DisasterGuide.typhoon,
                disasterRegion: '부산광역시 해운대구',
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/disaster-shelters',
          builder: (_, state) {
            openedRegion = state.extra as String?;
            return const Text('재난 지역 대피소');
          },
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.push('/guide');
    await tester.pumpAndSettle();

    expect(find.text('태풍 행동요령'), findsOneWidget);

    await tester.tap(find.text('가까운 대피소 보기'));
    await tester.pumpAndSettle();
    expect(openedRegion, '부산광역시 해운대구');

    router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_outlined));
    await tester.pumpAndSettle();
    expect(find.text('재난문자 상세'), findsOneWidget);
  });

  test('재난문자 유형으로 행동요령을 찾는다', () {
    expect(DisasterGuide.of('지진'), DisasterGuide.earthquake);
    expect(DisasterGuide.of('교통'), isNull);
  });
}
