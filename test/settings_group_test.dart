import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/core/widgets/settings_group.dart';
import 'package:musahi/features/setting/model/menu_model.dart';
import 'package:musahi/features/setting/widget/setting_menu_tile.dart';

void main() {
  testWidgets('탭 물결이 그룹 배경에 가려지지 않도록 그룹 안에 Material이 있다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsGroup(
            children: [
              SettingMenuTile(
                menuItem: SettingMenuItem(
                  icon: Icons.language,
                  title: '언어 설정',
                  subTitle: '한국어',
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(SettingsGroup),
        matching: find.byType(Material),
      ),
      findsOneWidget,
    );
    final inkWell = find.descendant(
      of: find.byType(SettingsGroup),
      matching: find.byType(InkWell),
    );
    expect(inkWell, findsOneWidget);
    expect(
      find.ancestor(of: inkWell, matching: find.byType(Material)),
      findsWidgets,
    );
  });
}
