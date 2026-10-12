import 'package:flutter/material.dart';

class SettingMenuItem {
  final IconData icon;
  final String title;
  final String? subTitle;
  final bool isSwitch;
  final VoidCallback? onPressed;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;


  const SettingMenuItem({
    required this.icon,
    required this.title,
    this.subTitle,
    this.isSwitch = false,
    this.onPressed,
    this.onSwitchChanged,
    this.switchValue = false,
  });
}