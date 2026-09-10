import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/features/setting/widget/language_selection_tile.dart';

enum AppLanguage {
  korean('한국어'),
  english('English'),
  chinese('中文'),
  japanese('日本語');

  final String label;

  const AppLanguage(this.label);
}

class LanguageChangePage extends StatefulWidget {
  const LanguageChangePage({super.key});

  @override
  State<LanguageChangePage> createState() => _LanguageChangePageState();
}

class _LanguageChangePageState extends State<LanguageChangePage> {
  AppLanguage _selected = AppLanguage.korean;

  void _onChanged(AppLanguage? language) {
    if (language == null) return;
    setState(() => _selected = language);
  }

  @override
  Widget build(BuildContext context) {
    final languages = AppLanguage.values;

    return BaseScaffold(
      appBar: const CustomAppBar(title: '언어 설정', icon: false),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.07),
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
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:[
                ...List.generate(languages.length, (index) {
                final language = languages[index];
                return LanguageSelectionTile<AppLanguage>(
                  languageName: language.label,
                  value: language,
                  groupValue: _selected,
                  onChanged: _onChanged,
                  showDivider: index != languages.length - 1,
                );
              }),
            ]),
          ),
        ),
      ),
    );
  }
}
