import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/features/setting/presentation/setting_detail/add_contact_page.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/widgets/custom_elevated_button.dart';
import 'package:musahi/l10n/app_localizations.dart';

void main() {
  testWidgets('서울 지역번호를 받고 잘못된 앞자리는 거부한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('ko'),
        home: AddContactPage(),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, '김민수');
    await tester.enterText(fields.last, '0212345678');
    await tester.pump();

    expect(find.text('02-1234-5678'), findsOneWidget);
    expect(
      tester
          .widget<CustomElevatedButton>(find.byType(CustomElevatedButton).last)
          .onPressed,
      isNotNull,
    );

    await tester.enterText(fields.last, '1230100000');
    await tester.pump();
    expect(
      tester
          .widget<CustomElevatedButton>(find.byType(CustomElevatedButton).last)
          .onPressed,
      isNull,
    );
  });

  testWidgets('비활성 버튼 글자는 흰색이 아니라 흐린 색으로 읽힌다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('ko'),
        home: AddContactPage(),
      ),
    );

    final label = tester.widget<Text>(
      find.descendant(
        of: find.byType(CustomElevatedButton).last,
        matching: find.byType(Text),
      ),
    );
    expect(label.style?.color, AppColors.muted);
  });

  testWidgets('서울 번호 11자리는 잘라서 통과시키지 않고 제출을 막고 이유를 알린다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('ko'),
        home: AddContactPage(),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, '김민수');
    await tester.enterText(fields.last, '02123456789');
    await tester.pump();

    // 입력한 숫자를 그대로 보여 주어야 사용자가 잘못을 알아본다.
    expect(find.text('02-12345-6789'), findsOneWidget);
    expect(find.text('02-1234-5678'), findsNothing);
    expect(find.textContaining('10자리까지'), findsOneWidget);
    expect(
      tester
          .widget<CustomElevatedButton>(find.byType(CustomElevatedButton).last)
          .onPressed,
      isNull,
    );

    await tester.enterText(fields.last, '0212345678');
    await tester.pump();
    expect(find.textContaining('10자리까지'), findsNothing);
    expect(
      tester
          .widget<CustomElevatedButton>(find.byType(CustomElevatedButton).last)
          .onPressed,
      isNotNull,
    );
  });
}
