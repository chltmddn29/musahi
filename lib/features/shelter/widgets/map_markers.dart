import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';

/// 현재 위치 점.
class CurrentLocationMarker extends StatelessWidget {
  static const double size = 28;

  const CurrentLocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.25),
      ),
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          border: Border.all(color: AppColors.surface, width: 3),
        ),
      ),
    );
  }
}

/// 물방울 모양 대피소 핀. 뾰족한 끝이 아래를 향한다.
class ShelterPinMarker extends StatelessWidget {
  static const double size = 30;

  /// 핀 중심에서 뾰족한 끝까지의 거리.
  static const double tipOffset = size * math.sqrt2 / 2;

  const ShelterPinMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -math.pi / 4,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(size / 2),
            topRight: Radius.circular(size / 2),
            bottomRight: Radius.circular(size / 2),
            bottomLeft: Radius.circular(2),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x2E000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
