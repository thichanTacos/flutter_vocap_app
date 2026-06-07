import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'app_ink_well.dart';

class CreateBottomSheet extends StatelessWidget {
  const CreateBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CreateBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: context.colors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            'Tạo mới',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _CreateOption(
            icon: Icons.style_outlined,
            iconColor: AppTheme.primary,
            title: 'Học phần',
            subtitle: 'Tạo bộ thẻ từ vựng mới',
            onTap: () {
              Navigator.pop(context);
              context.push('/deck/create');
            },
          ),
          const SizedBox(height: 10),

          _CreateOption(
            icon: Icons.folder_outlined,
            iconColor: AppTheme.secondary,
            title: 'Thư mục',
            subtitle: 'Lưu trữ các học phần liên quan',
            onTap: () {
              Navigator.pop(context);
              context.push('/folder/create');
            },
          ),
          const SizedBox(height: 10),

          _CreateOption(
            icon: Icons.group_outlined,
            iconColor: AppTheme.purple,
            title: 'Nhóm học',
            subtitle: 'Mời người khác cùng học',
            onTap: () {
              Navigator.pop(context);
              context.push('/group/create');
            },
          ),
        ],
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
