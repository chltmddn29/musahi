import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/notifications/notification_sync_status.dart';
import 'package:musahi/core/settings/notification_settings.dart';
import 'package:musahi/core/settings/text_size_settings.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/setting/model/menu_model.dart';
import 'package:musahi/features/setting/model/region_model.dart';
import 'package:musahi/features/setting/model/region_store.dart';
import 'package:musahi/features/setting/model/safety_contact_model.dart';
import 'package:musahi/features/setting/model/safety_contact_store.dart';
import 'package:musahi/features/setting/presentation/setting_detail/text_size_page.dart';
import 'package:musahi/features/setting/widget/setting_menu_tile.dart';
import 'package:musahi/l10n/app_localizations.dart';
import 'package:musahi/core/settings/language_settings.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BaseScaffold(
      appBar: CustomAppBar(title: l10n.settingsTitle, icon: false),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          const NotificationSyncStatus(),
          ListenableBuilder(
            listenable: Listenable.merge([
              disasterAlertEnabled,
              safetyGuideAlertEnabled,
            ]),
            builder: (context, _) => SettingsGroup(
              children: [
                SettingMenuTile(
                  menuItem: SettingMenuItem(
                    icon: Icons.notifications,
                    title: l10n.settingsDisasterAlert,
                    isSwitch: true,
                    switchValue: disasterAlertEnabled.value,
                    onSwitchChanged: setDisasterAlertEnabled,
                  ),
                ),
                SettingMenuTile(
                  menuItem: SettingMenuItem(
                    icon: Icons.check_circle_outline,
                    title: l10n.settingsSafetyAlert,
                    isSwitch: true,
                    switchValue: safetyGuideAlertEnabled.value,
                    onSwitchChanged: setSafetyGuideAlertEnabled,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ListenableBuilder(
            listenable: Listenable.merge([
              currentLanguage,
              textSizeStep,
              InterestRegionStore.instance.regions,
              InterestRegionStore.instance.primaryCd,
              SafetyContactStore.instance.contacts,
            ]),
            builder: (context, _) => SettingsGroup(
              children: _navItems(
                context,
                l10n,
                textSizeStepValue: textSizeStep.value,
                regions: InterestRegionStore.instance.regions.value,
                primaryCd: InterestRegionStore.instance.primaryCd.value,
                contacts: SafetyContactStore.instance.contacts.value,
              ).map((item) => SettingMenuTile(menuItem: item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<SettingMenuItem> _navItems(
    BuildContext context,
    AppLocalizations l10n, {
    required int textSizeStepValue,
    required List<RegionItem> regions,
    required String? primaryCd,
    required List<SafetyContact> contacts,
  }) {
    return [
      SettingMenuItem(
        icon: Icons.language,
        title: l10n.settingsLanguage,
        subTitle: currentLanguage.value.label,
        onPressed: () => context.push('/setting/language'),
      ),
      SettingMenuItem(
        icon: Icons.map,
        title: l10n.settingsRegions,
        subTitle: _regionSubtitle(l10n, regions, primaryCd),
        onPressed: () => context.push('/setting/region'),
      ),
      SettingMenuItem(
        icon: Icons.people,
        title: l10n.settingsContacts,
        subTitle: _contactSubtitle(l10n, contacts),
        onPressed: () => context.push('/setting/contacts'),
      ),
      SettingMenuItem(
        icon: Icons.text_fields,
        title: l10n.settingsTextSize,
        subTitle: TextSizePage.stepLabels(l10n)[textSizeStepValue],
        onPressed: () => context.push('/setting/text-size'),
      ),
    ];
  }

  String _regionSubtitle(
    AppLocalizations l10n,
    List<RegionItem> regions,
    String? primaryCd,
  ) {
    if (regions.isEmpty) return l10n.settingsNeedsSetup;
    final primary = regions.firstWhere(
      (r) => r.cd == primaryCd,
      orElse: () => regions.first,
    );
    final extraCount = regions.length - 1;
    return extraCount > 0
        ? l10n.settingsRegionSummary(primary.addrName, extraCount)
        : primary.addrName;
  }

  String _contactSubtitle(AppLocalizations l10n, List<SafetyContact> contacts) {
    return contacts.isEmpty
        ? l10n.settingsNeedsSetup
        : l10n.settingsContactCount(contacts.length);
  }
}
