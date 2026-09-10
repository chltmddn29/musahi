import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool icon;

  const CustomAppBar({super.key, required this.title, this.icon = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(color: AppColors.background),
      ),
      titleSpacing: 0,
      leading: icon
          ? GestureDetector(
              onTap: () => context.pop(),
              child: const Icon(
                Icons.arrow_back_ios_new_outlined,
                color: AppColors.background,
              ),
            )
          : const SizedBox(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
