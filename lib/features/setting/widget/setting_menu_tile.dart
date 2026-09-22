import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/features/setting/model/menu_model.dart';

class SettingMenuTile extends StatelessWidget {
  /// 스위치 행과 이동 행의 높이를 맞추는 기준값. 내용이 커지면(텍스트 확대) 늘어난다.
  static const double minHeight = 56;

  final SettingMenuItem menuItem;

  const SettingMenuTile({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context) {
    final row = Container(
      constraints: const BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Icon(menuItem.icon, size: 20, color: AppColors.muted),
          const SizedBox(width: 12),
          // 이동 행은 부제목과 3:2로 나눠 갖고, 스위치 행은 혼자 남은 공간을 모두
          // 흡수한다. 둘 다 tight flex라 남는 공간이 뒤로 새지 않아 우측 컨트롤이
          // 항상 같은 x에 붙는다.
          Expanded(
            flex: 3,
            child: Text(
              menuItem.title,
              style: AppTextStyles.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (menuItem.isSwitch)
            CupertinoSwitch(
              value: menuItem.switchValue,
              onChanged: menuItem.onSwitchChanged,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.surface,
            )
          else ...[
            Expanded(
              flex: 2,
              child: Text(
                menuItem.subTitle ?? '',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.muted,
            ),
          ],
        ],
      ),
    );

    if (menuItem.isSwitch) return row;
    return InkWell(onTap: menuItem.onPressed, child: row);
  }
}
