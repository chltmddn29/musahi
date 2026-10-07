import 'package:flutter_test/flutter_test.dart';
import 'package:musahi/core/settings/language_settings.dart';
import 'package:musahi/core/settings/notification_settings.dart';
import 'package:musahi/core/settings/text_size_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('text size step persists across reloads', () async {
    await loadTextSizeSetting();
    expect(textSizeStep.value, 1);

    await setTextSizeStep(3);
    expect(textSizeStep.value, 3);

    textSizeStep.value = 1; // simulate app restart before reload
    await loadTextSizeSetting();
    expect(textSizeStep.value, 3);
  });

  test('notification toggles persist across reloads', () async {
    await loadNotificationSettings();
    expect(disasterAlertEnabled.value, true);
    expect(safetyGuideAlertEnabled.value, false);

    await setDisasterAlertEnabled(false);
    await setSafetyGuideAlertEnabled(true);

    disasterAlertEnabled.value = true; // simulate app restart before reload
    safetyGuideAlertEnabled.value = false;
    await loadNotificationSettings();
    expect(disasterAlertEnabled.value, false);
    expect(safetyGuideAlertEnabled.value, true);
  });

  test('language selection persists across reloads', () async {
    await loadLanguageSetting();
    expect(currentLanguage.value, AppLanguage.korean);

    await setLanguage(AppLanguage.english);

    currentLanguage.value = AppLanguage.korean; // simulate app restart
    await loadLanguageSetting();
    expect(currentLanguage.value, AppLanguage.english);
  });
}
