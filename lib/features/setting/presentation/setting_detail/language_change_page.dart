import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/settings/language_settings.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/features/setting/widget/language_selection_tile.dart';

class LanguageChangePage extends StatelessWidget {
  const LanguageChangePage({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = AppLanguage.values;

    return BaseScaffold(
      appBar: const CustomAppBar(title: '언어 설정', icon: true),
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
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ValueListenableBuilder<AppLanguage>(
              valueListenable: currentLanguage,
              builder: (context, selected, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(languages.length, (index) {
                    final language = languages[index];
                    return LanguageSelectionTile<AppLanguage>(
                      languageName: language.label,
                      value: language,
                      groupValue: selected,
                      onChanged: (l) {
                        if (l != null) setLanguage(l);
                      },
                      showDivider: index != languages.length - 1,
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
