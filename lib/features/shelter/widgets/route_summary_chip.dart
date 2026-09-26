import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/utils/format_distance.dart';

/// "도보 8분 · 550m 남음" 요약 칩.
class RouteSummaryChip extends StatelessWidget {
  final Duration remainingTime;
  final int remainingMeters;

  const RouteSummaryChip({
    super.key,
    required this.remainingTime,
    required this.remainingMeters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '도보 ${(remainingTime.inSeconds / 60).ceil()}분 · ${formatDistance(remainingMeters)} 남음',
        style: AppTextStyles.label.copyWith(
          color: AppColors.text,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
