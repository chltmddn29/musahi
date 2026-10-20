import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/core/settings/language_settings.dart';
import 'package:musahi/features/setting/presentation/setting_detail/language_change_page.dart';
import 'package:musahi/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    currentLanguage.value = AppLanguage.korean;
  });
  tearDown(() => currentLanguage.value = AppLanguage.korean);

  Widget app() => ValueListenableBuilder<AppLanguage>(
    valueListenable: currentLanguage,
    builder: (context, language, _) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(language.languageCode),
      home: const LanguageChangePage(),
    ),
  );

  testWidgets('지원하는 언어만 보여주고 현재 언어를 선택 상태로 둔다', (tester) async {
    await tester.pumpWidget(app());

    expect(find.text('한국어'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('中文'), findsNothing);
    expect(find.text('日本語'), findsNothing);
    expect(
      tester.getSemantics(find.text('한국어')),
      isSemantics(isSelected: true),
    );
    expect(
      tester.getSemantics(find.text('English')),
      isSemantics(isSelected: false),
    );
  });

  testWidgets('English를 고르면 저장하고 화면 언어가 바뀐다', (tester) async {
    await tester.pumpWidget(app());
    expect(find.text('언어 설정'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(currentLanguage.value, AppLanguage.english);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_language'), AppLanguage.english.name);
    expect(find.text('Language'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('English')),
      isSemantics(isSelected: true),
    );
  });
}
