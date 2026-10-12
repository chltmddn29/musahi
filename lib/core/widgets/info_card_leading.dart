import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';

/// [InfoCard.leading] 슬롯용 아이콘·뱃지 3종.
class InfoCardLeading extends StatelessWidget {
  final Widget child;
  final double size;
  final Color background;
  final BorderRadius radius;

  const InfoCardLeading._({
    required this.child,
    required this.size,
    required this.background,
    required this.radius,
  });

  /// 번호 뱃지 (행동요령).
  factory InfoCardLeading.number(int value) => InfoCardLeading._(
    size: 28,
    background: AppColors.primary,
    radius: BorderRadius.circular(14),
    child: Text(
      '$value',
      style: AppTextStyles.label.copyWith(
        color: AppColors.surface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  /// 아이콘 박스. 기본 36, 설정 행은 [boxSize] 32.
  factory InfoCardLeading.icon(IconData icon, {double boxSize = 36}) =>
      InfoCardLeading._(
        size: boxSize,
        background: AppColors.primary.withValues(alpha: 0.1),
        radius: BorderRadius.circular(boxSize >= 36 ? 10 : 9),
        child: Icon(icon, size: boxSize / 2, color: AppColors.primary),
      );

  /// 이니셜 아바타 (연락처).
  factory InfoCardLeading.initial(String text) => InfoCardLeading._(
    size: 34,
    background: AppColors.primary.withValues(alpha: 0.12),
    radius: BorderRadius.circular(17),
    child: Text(
      text.isEmpty ? '' : text.characters.first,
      style: AppTextStyles.label.copyWith(
        color: AppColors.primary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, borderRadius: radius),
      child: child,
    );
  }
}
