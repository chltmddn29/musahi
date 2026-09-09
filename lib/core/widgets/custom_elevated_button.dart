import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';

class CustomElevatedButton extends StatelessWidget {
  final void Function() onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String child;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: backgroundColor ?? AppColors.primary,
      ),
      onPressed: onPressed,
      child: Text(
        child,
        style: AppTextStyles.bodyLarge.copyWith(
          color: foregroundColor ?? AppColors.surface,
        ),
      ),
    );
  }
}
