import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/utils/format_distance.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/shelter/model/shelter_route.dart';

/// 하단 안내 패널: 다음 안내 지점 + 목적지까지 거리 + 안내 종료 버튼.
class RouteGuidancePanel extends StatelessWidget {
  final RouteStep nextStep;
  final String destinationName;
  final int remainingMeters;
  final VoidCallback onEnd;

  const RouteGuidancePanel({
    super.key,
    required this.nextStep,
    required this.destinationName,
    required this.remainingMeters,
    required this.onEnd,
  });

  static IconData _iconOf(TurnDirection direction) => switch (direction) {
    TurnDirection.straight => Icons.arrow_upward,
    TurnDirection.left => Icons.turn_left,
    TurnDirection.right => Icons.turn_right,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                InfoCardLeading.icon(_iconOf(nextStep.direction), boxSize: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nextStep.description,
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 2),
                      CaptionText(
                        '$destinationName까지 ${formatDistance(remainingMeters)}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onEnd,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.muted,
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: Color(0xFFE5E5EA), width: 1.5),
                textStyle: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('안내 종료'),
            ),
          ],
        ),
      ),
    );
  }
}
