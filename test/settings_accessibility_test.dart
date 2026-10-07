import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/features/setting/widget/language_selection_tile.dart';

void main() {
  testWidgets('language selection has one label and selected/enabled states', (
    tester,
  ) async {
    String? selection = 'English';
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                for (final language in ['English', 'Korean'])
                  LanguageSelectionTile(
                    languageName: language,
                    value: language,
                    groupValue: selection,
                    onChanged: (value) => setState(() => selection = value),
                  ),
                const LanguageSelectionTile(
                  languageName: 'Disabled',
                  value: 'Disabled',
                  groupValue: null,
                  onChanged: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final english = tester.getSemantics(find.text('English'));
    expect(
      english,
      isSemantics(
        label: 'English',
        isButton: true,
        isSelected: true,
        isEnabled: true,
      ),
    );
    expect(
      tester.getSemantics(find.text('Disabled')),
      isSemantics(isEnabled: false),
    );
    await tester.tap(find.text('Korean'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Korean')),
      isSemantics(isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('English')),
      isSemantics(isSelected: false),
    );
  });

  testWidgets('back button exposes tooltip and pops the route', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Home')),
          routes: [
            GoRoute(
              path: 'detail',
              builder: (_, _) =>
                  const Scaffold(appBar: CustomAppBar(title: 'Detail')),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    router.push('/detail');
    await tester.pumpAndSettle();
    final back = find.byTooltip('Back');
    expect(tester.getSemantics(back), isSemantics(isButton: true));
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Detail'), findsNothing);
  });
}
