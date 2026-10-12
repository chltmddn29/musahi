import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _textSizeStepKey = 'text_size_step';

/// 앱 전역 텍스트 크기 단계 (0=작게, 1=보통, 2=크게, 3=매우크게).
///
/// 별도 상태관리 패키지가 없어 [goRouter]처럼 전역 [ValueNotifier]로 관리한다.
/// 값을 읽을 화면은 `ValueListenableBuilder`로 구독하면 된다.
/// [loadTextSizeSetting]으로 불러온 뒤에는 [setTextSizeStep]으로 값을 바꿀 때마다
/// [SharedPreferences]에 저장해 앱을 재실행해도 유지된다.
final ValueNotifier<int> textSizeStep = ValueNotifier<int>(1);

Future<void> loadTextSizeSetting() async {
  final prefs = await SharedPreferences.getInstance();
  textSizeStep.value = prefs.getInt(_textSizeStepKey) ?? 1;
}

Future<void> setTextSizeStep(int step) async {
  textSizeStep.value = step;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_textSizeStepKey, step);
}

/// 단계별 라벨. 인덱스가 곧 단계 값이다.
const List<String> textSizeStepLabels = ['작게', '보통', '크게', '매우크게'];

/// 단계별 실제 폰트 크기(sp). [textSizeStepLabels]와 인덱스가 대응된다.
const List<double> textSizeStepFontSizes = [14, 17, 21, 26];

/// [step] 단계에 해당하는 전역 텍스트 배율.
///
/// '보통'(index 1)을 기준(1.0)으로 삼아, [MediaQuery]의 textScaler에 적용한다.
double textScaleForStep(int step) =>
    textSizeStepFontSizes[step] / textSizeStepFontSizes[1];

/// [platformScaler](시스템 접근성 설정)에 앱의 [step] 배율을 곱해서 합성한다.
///
/// 단순히 [TextScaler.linear]로 교체하면 사용자가 켜둔 OS 수준 글자 확대
/// 설정이 앱 실행 중 사라지므로, 두 배율을 곱해 함께 적용한다.
TextScaler composeTextScaler(TextScaler platformScaler, int step) {
  return _ComposedTextScaler(platformScaler, textScaleForStep(step));
}

class _ComposedTextScaler extends TextScaler {
  const _ComposedTextScaler(this._base, this._factor);

  final TextScaler _base;
  final double _factor;

  @override
  double scale(double fontSize) => _base.scale(fontSize) * _factor;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => _base.textScaleFactor * _factor;

  @override
  bool operator ==(Object other) =>
      other is _ComposedTextScaler &&
      other._base == _base &&
      other._factor == _factor;

  @override
  int get hashCode => Object.hash(_base, _factor);
}
