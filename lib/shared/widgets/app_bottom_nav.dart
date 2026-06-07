import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'app_ink_well.dart';
import 'create_bottom_sheet.dart';

enum BottomNavTab { home, create, library, profile }

class AppBottomNav extends StatelessWidget {
  final BottomNavTab activeTab;

  const AppBottomNav({
    super.key,
    required this.activeTab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Trang chủ',
                isActive: activeTab == BottomNavTab.home,
                activeColor: AppTheme.primary,
                onTap: () {
                  if (activeTab != BottomNavTab.home) context.go('/home');
                },
              ),
              _NavItem(
                icon: Icons.add_circle_rounded,
                label: 'Tạo',
                isActive: activeTab == BottomNavTab.create,
                activeColor: AppTheme.secondary,
                onTap: () => CreateBottomSheet.show(context),
              ),
              _NavItem(
                icon: Icons.folder_rounded,
                label: 'Thư viện',
                isActive: activeTab == BottomNavTab.library,
                activeColor: AppTheme.purple,
                onTap: () {
                  if (activeTab != BottomNavTab.library) context.push('/library');
                },
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Cá nhân',
                isActive: activeTab == BottomNavTab.profile,
                activeColor: AppTheme.blue,
                onTap: () {
                  if (activeTab != BottomNavTab.profile) context.push('/profile');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.activeColor,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18 : 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? activeColor : context.colors.textTertiary,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: activeColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
