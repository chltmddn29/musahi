import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/settings/language_settings.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/features/setting/widget/language_selection_tile.dart';
import 'package:musahi/l10n/app_localizations.dart';

class LanguageChangePage extends StatelessWidget {
  const LanguageChangePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).settingsLanguage,
        icon: true,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.07,
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider),
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: ValueListenableBuilder<AppLanguage>(
            valueListenable: currentLanguage,
            builder: (context, current, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final language in supportedLanguages)
                  LanguageSelectionTile<AppLanguage>(
                    languageName: language.label,
                    value: language,
                    groupValue: current,
                    onChanged: (selected) => setLanguage(selected!),
                    showDivider: language != supportedLanguages.last,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
