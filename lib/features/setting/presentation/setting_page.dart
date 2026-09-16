import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/settings/notification_settings.dart';
import 'package:musahi/core/settings/text_size_settings.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/features/setting/model/menu_model.dart';
import 'package:musahi/features/setting/model/region_model.dart';
import 'package:musahi/features/setting/model/region_store.dart';
import 'package:musahi/features/setting/model/safety_contact_model.dart';
import 'package:musahi/features/setting/model/safety_contact_store.dart';
import 'package:musahi/features/setting/presentation/setting_detail/text_size_page.dart';
import 'package:musahi/features/setting/widget/setting_menu_tile.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: const CustomAppBar(title: '설정', icon: false),
      child: ListView(
        children: [
          const SizedBox(height: 100),
          ListenableBuilder(
            listenable: Listenable.merge([
              disasterAlertEnabled,
              safetyGuideAlertEnabled,
            ]),
            builder: (context, _) => _buildGroup([
              SettingMenuItem(
                icon: Icons.notifications,
                title: '재난문자 알림',
                isSwitch: true,
                switchValue: disasterAlertEnabled.value,
                onSwitchChanged: setDisasterAlertEnabled,
              ),
              SettingMenuItem(
                icon: Icons.check_circle_outline,
                title: '안전 안내 알림',
                isSwitch: true,
                switchValue: safetyGuideAlertEnabled.value,
                onSwitchChanged: setSafetyGuideAlertEnabled,
              ),
            ]),
          ),
          const SizedBox(height: 40),
          ListenableBuilder(
            listenable: Listenable.merge([
              textSizeStep,
              InterestRegionStore.instance.regions,
              InterestRegionStore.instance.primaryCd,
              SafetyContactStore.instance.contacts,
            ]),
            builder: (context, _) => _buildGroup(
              _navItems(
                context,
                textSizeStep.value,
                InterestRegionStore.instance.regions.value,
                InterestRegionStore.instance.primaryCd.value,
                SafetyContactStore.instance.contacts.value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<SettingMenuItem> _navItems(
    BuildContext context,
    int textSizeStepValue,
    List<RegionItem> regions,
    String? primaryCd,
    List<SafetyContact> contacts,
  ) {
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
        subTitle: _regionSubtitle(regions, primaryCd),
        onPressed: () => context.push('/setting/region'),
      ),
      SettingMenuItem(
        icon: Icons.people,
        title: '안전 연락처 관리',
        subTitle: _contactSubtitle(contacts),
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

  String _regionSubtitle(List<RegionItem> regions, String? primaryCd) {
    if (regions.isEmpty) return '설정 필요';
    final primary = regions.firstWhere(
      (r) => r.cd == primaryCd,
      orElse: () => regions.first,
    );
    final extraCount = regions.length - 1;
    return extraCount > 0
        ? '${primary.addrName} 외 $extraCount곳'
        : primary.addrName;
  }

  String _contactSubtitle(List<SafetyContact> contacts) {
    return contacts.isEmpty ? '설정 필요' : '${contacts.length}명';
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
