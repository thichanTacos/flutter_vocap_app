import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/widgets/app_ink_well.dart';
import '../../../../../shared/widgets/create_bottom_sheet.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B2E),
        border: const Border(
            top: BorderSide(color: Color(0xFF2A2640), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Trang chủ',
                isActive: true,
                activeGradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)],
                ),
              ),
              _NavItem(
                icon: Icons.add_circle_rounded,
                label: 'Tạo',
                activeGradient: const LinearGradient(
                  colors: [Color(0xFF00D4AA), Color(0xFF00B4D8)],
                ),
                onTap: () => CreateBottomSheet.show(context),
              ),
              _NavItem(
                icon: Icons.folder_rounded,
                label: 'Thư viện',
                activeGradient: const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFFF8C42)],
                ),
                onTap: () => context.push('/library'),
              ),
              _NavItem(
                icon: Icons.workspace_premium_rounded,
                label: 'Thử miễn phí',
                activeGradient: const LinearGradient(
                  colors: [Color(0xFFFFD93D), Color(0xFFFF6B35)],
                ),
                onTap: () {},
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
  final LinearGradient activeGradient;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.activeGradient,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon với gradient khi active
            isActive
                ? ShaderMask(
              shaderCallback: (bounds) =>
                  activeGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Icon(icon, size: 28, color: Colors.white),
            )
                : Icon(icon, size: 26, color: Colors.grey[600]),

            const SizedBox(height: 4),

            // Label
            isActive
                ? ShaderMask(
              shaderCallback: (bounds) =>
                  activeGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
                : Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
                fontWeight: FontWeight.normal,
              ),
            ),

            // Dot indicator khi active
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 20 : 0,
              height: isActive ? 3 : 0,
              decoration: BoxDecoration(
                gradient: isActive ? activeGradient : null,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}