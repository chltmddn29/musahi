import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/settings/text_size_settings.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/l10n/app_localizations.dart';

class TextSizePage extends StatefulWidget {
  const TextSizePage({super.key, this.initialStep = 1, this.onChanged});

  /// 단계별 라벨. 인덱스가 곧 단계 값이다.
  static List<String> stepLabels(AppLocalizations l10n) => [
    l10n.textSizeSmall,
    l10n.textSizeNormal,
    l10n.textSizeLarge,
    l10n.textSizeExtraLarge,
  ];

  /// 단계별 실제 폰트 크기(sp). [stepLabels]와 인덱스가 대응된다.
  static const List<double> fontSizes = textSizeStepFontSizes;

  final int initialStep;

  final ValueChanged<double>? onChanged;

  @override
  State<TextSizePage> createState() => _TextSizePageState();
}

class _TextSizePageState extends State<TextSizePage> {
  static const List<double> _fontSizes = TextSizePage.fontSizes;

  late int _stepIndex;

  @override
  void initState() {
    super.initState();
    _stepIndex = widget.initialStep.clamp(0, _fontSizes.length - 1);
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
    final l10n = AppLocalizations.of(context);
    final labels = TextSizePage.stepLabels(l10n);
    return BaseScaffold(
      appBar: CustomAppBar(title: l10n.settingsTextSize, icon: true),
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
                child: Text(l10n.textSizeSample),
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
                max: (labels.length - 1).toDouble(),
                divisions: labels.length - 1,
                onChanged: _onSliderChanged,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(labels.length, (index) {
                  final isSelected = index == _stepIndex;
                  return Text(
                    labels[index],
                    style: AppTextStyles.label.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected ? AppColors.primary : AppColors.muted,
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
