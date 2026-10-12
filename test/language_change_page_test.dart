import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/features/setting/presentation/setting_detail/language_change_page.dart';

void main() {
  testWidgets('현재 지원하는 언어만 안내한다', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LanguageChangePage()));

    expect(find.text('한국어'), findsOneWidget);
    expect(find.text('현재 한국어만 지원합니다.'), findsOneWidget);
    expect(find.text('English'), findsNothing);
  });
}
