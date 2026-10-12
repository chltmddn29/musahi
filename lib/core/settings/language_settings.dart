import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _languageKey = 'app_language';

enum AppLanguage {
  korean('한국어'),
  english('English'),
  chinese('中文'),
  japanese('日本語');

  final String label;

  const AppLanguage(this.label);
}

/// 앱 전역 언어 설정.
///
/// [textSizeStep]처럼 전역 [ValueNotifier]로 관리한다. [loadLanguageSetting]으로
/// 불러온 뒤에는 [setLanguage]로 값을 바꿀 때마다 [SharedPreferences]에 저장해 앱을
/// 재실행해도 유지된다.
final ValueNotifier<AppLanguage> currentLanguage = ValueNotifier<AppLanguage>(
  AppLanguage.korean,
);

Future<void> loadLanguageSetting() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_languageKey);
  if (saved == null) return;
  currentLanguage.value = AppLanguage.values.firstWhere(
    (language) => language.name == saved,
    orElse: () => AppLanguage.korean,
  );
}

Future<void> setLanguage(AppLanguage language) async {
  currentLanguage.value = language;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_languageKey, language.name);
}
