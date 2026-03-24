import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

enum AppBottomNavItem { home, scan, wishlist, history, profile }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.current});

  final AppBottomNavItem current;

  static const _activeColor = Color(0xFF2ECC71);
  static const _inactiveColor = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TabItem(
            icon: Icons.home_outlined,
            label: 'Trang chủ',
            active: current == AppBottomNavItem.home,
            onTap: () => _navigate(context, AppBottomNavItem.home),
          ),
          _TabItem(
            icon: Icons.favorite_border,
            label: 'Yêu thích',
            active: current == AppBottomNavItem.wishlist,
            onTap: () => _navigate(context, AppBottomNavItem.wishlist),
          ),
          _TabItem(
            icon: Icons.history,
            label: 'Lịch sử',
            active: current == AppBottomNavItem.history,
            onTap: () => _navigate(context, AppBottomNavItem.history),
          ),
          _TabItem(
            icon: Icons.person_outline,
            label: 'Hồ sơ',
            active: current == AppBottomNavItem.profile,
            onTap: () => _navigate(context, AppBottomNavItem.profile),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, AppBottomNavItem target) {
    if (target == current) {
      return;
    }

    String routeName;
    switch (target) {
      case AppBottomNavItem.home:
        routeName = AppRoutes.home;
        break;
      case AppBottomNavItem.scan:
        routeName = AppRoutes.scan;
        break;
      case AppBottomNavItem.wishlist:
        routeName = AppRoutes.wishlist;
        break;
      case AppBottomNavItem.history:
        routeName = AppRoutes.scanHistory;
        break;
      case AppBottomNavItem.profile:
        routeName = AppRoutes.profile;
        break;
    }

    Navigator.of(context).pushNamed(routeName);
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        active ? AppBottomNav._activeColor : AppBottomNav._inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
