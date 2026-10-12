import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';

/// 지도 위에 띄우는 원형 뒤로가기 버튼.
class MapBackButton extends StatelessWidget {
  const MapBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => context.pop(),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: AppColors.text,
        ),
      ),
    );
  }
}
