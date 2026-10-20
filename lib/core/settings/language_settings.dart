import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _languageKey = 'app_language';

enum AppLanguage {
  korean('한국어', 'ko'),
  english('English', 'en'),
  chinese('中文', 'zh'),
  japanese('日本語', 'ja');

  final String label;
  final String languageCode;

  const AppLanguage(this.label, this.languageCode);
}

const supportedLanguages = [AppLanguage.korean, AppLanguage.english];

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
  // 번역이 없는 언어가 이전 버전에서 저장됐을 수 있어 지원 언어만 복원한다.
  currentLanguage.value = supportedLanguages.contains(restored)
      ? restored
      : AppLanguage.korean;
}

Future<void> setLanguage(AppLanguage language) async {
  currentLanguage.value = language;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_languageKey, language.name);
}
