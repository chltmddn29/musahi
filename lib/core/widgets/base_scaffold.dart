import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';

class BaseScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomBar;
  final Color? backgroundColor;

  const BaseScaffold({
    super.key,
    required this.child,
    required this.appBar,
    this.bottomBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      bottomNavigationBar: bottomBar,
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: child,
      ),
    );
  }
}
