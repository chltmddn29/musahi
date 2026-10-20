import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/utils/format_distance.dart';
import 'package:musahi/core/utils/format_duration.dart';
import 'package:musahi/l10n/app_localizations.dart';

/// "도보 8분 · 550m 남음" 요약 칩.
class RouteSummaryChip extends StatelessWidget {
  final Duration remainingTime;
  final int remainingMeters;
  final bool isEstimated;

  const RouteSummaryChip({
    super.key,
    required this.remainingTime,
    required this.remainingMeters,
    this.isEstimated = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final distance = formatDistance(remainingMeters);
    final duration = formatDuration(l10n, remainingTime);
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
        isEstimated
            ? l10n.routeSummaryEstimated(distance, duration)
            : l10n.routeSummary(duration, distance),
        style: AppTextStyles.label.copyWith(
          color: AppColors.text,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
