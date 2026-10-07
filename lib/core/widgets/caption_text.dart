import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';

/// 캡션 크기. [small] 12.5sp(리스트 보조텍스트), [medium] 14sp(온보딩 설명문).
enum CaptionSize { small, medium }

/// 제목 아래 회색 보조 텍스트.
class CaptionText extends StatelessWidget {
  final String text;
  final CaptionSize size;
  final TextAlign align;
  final int? maxLines;

  /// 컬러 배경 위에 올릴 때 true → 흰색.
  final bool onColor;

  const CaptionText(
    this.text, {
    super.key,
    this.size = CaptionSize.small,
    this.align = TextAlign.start,
    this.maxLines,
    this.onColor = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = switch (size) {
      CaptionSize.small => AppTextStyles.captionSmall,
      CaptionSize.medium => AppTextStyles.captionMedium,
    };

    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: onColor
          ? base.copyWith(color: AppColors.surface.withValues(alpha: 0.9))
          : base,
    );
  }
}
