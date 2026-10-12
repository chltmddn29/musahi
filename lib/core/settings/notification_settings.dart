import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _disasterAlertKey = 'disaster_alert_enabled';
const _safetyGuideAlertKey = 'safety_guide_alert_enabled';

/// 재난문자 알림, 안전 안내 알림 on/off.
///
/// [textSizeStep]처럼 전역 [ValueNotifier]로 관리한다. [loadNotificationSettings]로
/// 불러온 뒤에는 [setDisasterAlertEnabled], [setSafetyGuideAlertEnabled]로 값을 바꿀
/// 때마다 [SharedPreferences]에 저장해 앱을 재실행해도 유지된다.
final ValueNotifier<bool> disasterAlertEnabled = ValueNotifier<bool>(true);
final ValueNotifier<bool> safetyGuideAlertEnabled = ValueNotifier<bool>(false);

Future<void> loadNotificationSettings() async {
  final prefs = await SharedPreferences.getInstance();
  disasterAlertEnabled.value = prefs.getBool(_disasterAlertKey) ?? true;
  safetyGuideAlertEnabled.value = prefs.getBool(_safetyGuideAlertKey) ?? false;
}

Future<void> setDisasterAlertEnabled(bool value) async {
  disasterAlertEnabled.value = value;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_disasterAlertKey, value);
}

Future<void> setSafetyGuideAlertEnabled(bool value) async {
  safetyGuideAlertEnabled.value = value;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_safetyGuideAlertKey, value);
}
