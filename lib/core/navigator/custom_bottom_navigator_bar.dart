import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/l10n/app_localizations.dart';

class CustomBottomNavigatorBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomBottomNavigatorBar({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  static const _navIconTheme = IconThemeData(size: 24);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        enableFeedback: true,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: AppColors.muted,
        selectedItemColor: AppColors.primary,
        unselectedFontSize: 12,
        selectedFontSize: 12,
        selectedIconTheme: _navIconTheme,
        unselectedIconTheme: _navIconTheme,
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_outlined),
            label: l10n.navAlerts,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.location_on_outlined),
            label: l10n.navLocation,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: l10n.navGuide,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.share_outlined),
            label: l10n.navShare,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
