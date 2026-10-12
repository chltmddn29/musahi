import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/features/setting/model/menu_model.dart';

class SettingMenuTile extends StatelessWidget {
  final SettingMenuItem menuItem;

  const SettingMenuTile({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(menuItem.icon),
          const SizedBox(width: 10),
          Text(menuItem.title, style: AppTextStyles.label),
          const Spacer(),
          menuItem.isSwitch
              ? CupertinoSwitch(
                  value: menuItem.switchValue,
                  onChanged: menuItem.onSwitchChanged,
                  activeTrackColor: AppColors.primary,
                  trackColor: AppColors.divider,
                  thumbColor: AppColors.surface,
                )
              : iconButton,
        ],
      ),
    );
  }

  Widget get iconButton => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        menuItem.subTitle ?? '',
        style: AppTextStyles.label.copyWith(color: AppColors.primary),
      ),
      IconButton(
        onPressed: menuItem.onPressed,
        icon: const Icon(Icons.arrow_forward_ios),
      ),
    ],
  );
}
