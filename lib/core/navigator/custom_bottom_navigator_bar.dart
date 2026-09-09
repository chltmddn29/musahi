import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';

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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: '알림',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: '위치',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '행동요령'),
          BottomNavigationBarItem(
            icon: Icon(Icons.share_outlined),
            label: '공유',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}
