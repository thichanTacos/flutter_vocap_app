import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class ProfileAchievement extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const ProfileAchievement({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final hasStreak = currentStreak > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Flame icon
          hasStreak ? _ActiveFlame(days: currentStreak) : const _EmptyFlame(),

          const SizedBox(height: 14),

          Text(
            hasStreak
                ? 'Chuỗi $currentStreak ngày liên tiếp!'
                : 'Hiện chưa có chuỗi nào',
            style: TextStyle(
              color: hasStreak ? context.colors.textPrimary : context.colors.textSecondary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            hasStreak
                ? 'Học vào ngày mai để duy trì chuỗi!'
                : 'Hãy học để bắt đầu chuỗi mới của bạn!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textTertiary,
              fontSize: 13,
            ),
          ),

          if (longestStreak > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(
                    'Kỷ lục: $longestStreak ngày',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Flame khi có chuỗi ────────────────────────────────────────────────────────
class _ActiveFlame extends StatelessWidget {
  final int days;
  const _ActiveFlame({required this.days});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Glow background
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.primary.withValues(alpha: 0.15),
                AppTheme.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        const Text('🔥', style: TextStyle(fontSize: 52)),
        // Day badge
        Positioned(
          bottom: 0,
          child: Container(
            constraints: const BoxConstraints(minWidth: 28),
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, Color(0xFFFF8C42)],
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$days',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Flame khi chưa có chuỗi ──────────────────────────────────────────────────
class _EmptyFlame extends StatelessWidget {
  const _EmptyFlame();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.surface,
        border: Border.all(
          color: context.colors.divider,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.local_fire_department_rounded,
          size: 38,
          color: context.colors.textTertiary,
        ),
      ),
    );
  }
}
