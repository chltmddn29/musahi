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

const _supportedLanguages = {AppLanguage.korean};

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
  final restored = AppLanguage.values.firstWhere(
    (language) => language.name == saved,
    orElse: () => AppLanguage.korean,
  );
  // 언어 화면이 한국어만 보여 주므로, 이전 버전에서 저장된 다른 언어는 복원하지 않는다.
  currentLanguage.value = _supportedLanguages.contains(restored)
      ? restored
      : AppLanguage.korean;
}

Future<void> setLanguage(AppLanguage language) async {
  currentLanguage.value = language;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_languageKey, language.name);
}
