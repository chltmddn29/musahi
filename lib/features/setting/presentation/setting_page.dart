import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/settings/text_size_settings.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/features/setting/model/menu_model.dart';
import 'package:musahi/features/setting/presentation/setting_detail/text_size_page.dart';
import 'package:musahi/features/setting/widget/setting_menu_tile.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final switchValues = [true, false];

  @override
  Widget build(BuildContext context) {
    final toggleItems = [
      SettingMenuItem(
        icon: Icons.notifications,
        title: '재난문자 알림',
        isSwitch: true,
        switchValue: switchValues[0],
        onSwitchChanged: (v) => setState(() => switchValues[0] = v),
      ),
      SettingMenuItem(
        icon: Icons.check_circle_outline,
        title: '안전 안내 알림',
        isSwitch: true,
        switchValue: switchValues[1],
        onSwitchChanged: (v) => setState(() => switchValues[1] = v),
      ),
    ];
    return BaseScaffold(
      appBar: const CustomAppBar(title: '설정', icon: false),
      child: ListView(
        children: [
          const SizedBox(height: 100),
          _buildGroup(toggleItems),
          const SizedBox(height: 40),
          ValueListenableBuilder<int>(
            valueListenable: textSizeStep,
            builder: (context, step, _) => _buildGroup(_navItems(context, step)),
          ),
        ],
      ),
    );
  }

  List<SettingMenuItem> _navItems(BuildContext context, int textSizeStepValue) {
    return [
      SettingMenuItem(
        icon: Icons.language,
        title: '언어 설정',
        subTitle: '한국어',
        onPressed: () => context.push('/setting/language'),
      ),
      SettingMenuItem(
        icon: Icons.map,
        title: '관심지역 관리',
        subTitle: '서울 강남구 외 1곳',
        onPressed: () => context.push('/setting/region'),
      ),
      SettingMenuItem(
        icon: Icons.people,
        title: '안전 연락처 관리',
        subTitle: '2명',
        onPressed: () => context.push('/setting/contacts'),
      ),
      SettingMenuItem(
        icon: Icons.text_fields,
        title: '텍스트 크기 조절',
        subTitle: TextSizePage.stepLabels[textSizeStepValue],
        onPressed: () => context.push('/setting/text-size'),
      ),
    ];
  }
}

Widget _buildGroup(List<SettingMenuItem> items) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          SettingMenuTile(menuItem: items[i]),
          if (i != items.length - 1)
            const Divider(height: 1, color: AppColors.divider, thickness: 2),
        ],
      ],
    ),
  );
}
