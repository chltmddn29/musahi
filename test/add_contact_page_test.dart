import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/features/setting/presentation/setting_detail/add_contact_page.dart';
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
}
