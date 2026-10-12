import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/features/setting/presentation/setting_detail/add_contact_page.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/widgets/custom_elevated_button.dart';

void main() {
  testWidgets('서울 지역번호를 받고 잘못된 앞자리는 거부한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddContactPage()));

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
    await tester.pumpWidget(const MaterialApp(home: AddContactPage()));

    final label = tester.widget<Text>(
      find.descendant(
        of: find.byType(CustomElevatedButton).last,
        matching: find.byType(Text),
      ),
    );
    expect(label.style?.color, AppColors.muted);
  });

  testWidgets('서울 번호는 10자리를 넘겨 입력해도 제출 가능한 형식으로 잘린다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddContactPage()));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, '김민수');
    await tester.enterText(fields.last, '02123456789');
    await tester.pump();

    expect(find.text('02-1234-5678'), findsOneWidget);
    expect(
      tester
          .widget<CustomElevatedButton>(find.byType(CustomElevatedButton).last)
          .onPressed,
      isNotNull,
    );
  });
}
