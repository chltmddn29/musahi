import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';

class TextSizePage extends StatefulWidget {
  const TextSizePage({super.key, this.initialStep = 1, this.onChanged});

  /// 단계별 라벨. 인덱스가 곧 단계 값이다.
  static const List<String> stepLabels = ['작게', '보통', '크게', '매우크게'];

  /// 단계별 실제 폰트 크기(sp). [stepLabels]와 인덱스가 대응된다.
  static const List<double> fontSizes = [14, 17, 21, 26];

  final int initialStep;

  final ValueChanged<double>? onChanged;

  @override
  State<TextSizePage> createState() => _TextSizePageState();
}

class _TextSizePageState extends State<TextSizePage> {
  static const List<String> _labels = TextSizePage.stepLabels;
  static const List<double> _fontSizes = TextSizePage.fontSizes;

  late int _stepIndex;

  @override
  void initState() {
    super.initState();
    _stepIndex = widget.initialStep.clamp(0, _labels.length - 1);
  }

  double get _currentFontSize => _fontSizes[_stepIndex];

  void _onSliderChanged(double value) {
    final rounded = value.round();
    if (rounded == _stepIndex) return;
    setState(() => _stepIndex = rounded);
    widget.onChanged?.call(_currentFontSize);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: const CustomAppBar(title: '텍스트 크기 조절', icon: true),
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.cardShadow,
              ),
              alignment: Alignment.center,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontSize: _currentFontSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
                child: const Text('재난 문자 예시입니다'),
              ),
            ),
            const SizedBox(height: 32),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.divider,
                thumbColor: AppColors.surface,
                overlayColor: AppColors.primary.withValues(alpha: 0.12),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 11,
                  elevation: 2,
                ),
                trackHeight: 3,
              ),
              child: Slider(
                value: _stepIndex.toDouble(),
                min: 0,
                max: (_labels.length - 1).toDouble(),
                divisions: _labels.length - 1,
                onChanged: _onSliderChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_labels.length, (index) {
                  final isSelected = index == _stepIndex;
                  return Text(
                    _labels[index],
                    style: AppTextStyles.label.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.muted,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
