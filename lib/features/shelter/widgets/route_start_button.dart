import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/utils/format_distance.dart';
import 'package:musahi/core/widgets/info_card.dart';

/// 경로 안내 시작 버튼. 도보 거리를 넘는 대피소는 한 번 더 눌러야 시작한다.
/// 대피소가 바뀌면 확인 상태를 초기화하도록 대피소 id를 key로 넘긴다.
class RouteStartButton extends StatefulWidget {
  /// 도보 안내가 의미 있는 거리.
  static const walkingLimitMeters = 5000;

  final int? distanceMeters;
  final VoidCallback? onPressed;

  const RouteStartButton({
    super.key,
    required this.distanceMeters,
    required this.onPressed,
  });

  @override
  State<RouteStartButton> createState() => _RouteStartButtonState();
}

class _RouteStartButtonState extends State<RouteStartButton> {
  bool _awaitingConfirm = false;

  bool get _isFar =>
      (widget.distanceMeters ?? 0) > RouteStartButton.walkingLimitMeters;

  void _handlePressed() {
    if (_isFar && !_awaitingConfirm) {
      setState(() => _awaitingConfirm = true);
      return;
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_awaitingConfirm) ...[
          CaptionText(
            '도보로 가기엔 먼 거리입니다(${formatDistance(widget.distanceMeters!)}). '
            '한 번 더 누르면 경로 안내를 시작합니다.',
            align: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
        ElevatedButton.icon(
          onPressed: widget.onPressed == null ? null : _handlePressed,
          icon: const Icon(Icons.navigation, size: 18),
          label: Text(_awaitingConfirm ? '한 번 더 눌러 경로 안내 시작' : '경로 안내 시작'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _awaitingConfirm
                ? AppColors.alertUrgent
                : AppColors.primary,
            foregroundColor: AppColors.surface,
            elevation: 0,
            minimumSize: const Size.fromHeight(54),
            textStyle: AppTextStyles.button,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}
