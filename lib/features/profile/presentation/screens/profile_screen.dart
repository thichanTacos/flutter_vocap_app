import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../deck/providers/deck_provider.dart';
import '../../providers/streak_provider.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_achievement.dart';
import '../widgets/profile_streak_calendar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final decksAsync = ref.watch(userDecksProvider);
    final decks = decksAsync.valueOrNull ?? [];
    final totalCards = decks.fold<int>(0, (sum, d) => sum + d.cardCount);
    final streak =
        ref.watch(userStreakProvider).valueOrNull ?? const StreakModel();

    final email = user?.email ?? '';
    final displayName = user?.displayName ??
        (email.isNotEmpty ? email.split('@')[0] : 'Người dùng');
    final initial = displayName[0].toUpperCase();

    return Scaffold(
      backgroundColor: context.colors.bg,
      bottomNavigationBar: const AppBottomNav(activeTab: BottomNavTab.profile),
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Hồ sơ',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _VipButton(onTap: () {}),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // ── Avatar + Name ──────────────────────────────
            _AvatarSection(
              initial: initial,
              displayName: displayName,
              totalDecks: decks.length,
              totalCards: totalCards,
              streakDays: streak.currentStreak,
            ),

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Menu items ─────────────────────────
                  ProfileMenuItem(
                    icon: Icons.settings_rounded,
                    label: 'Cài đặt của bạn',
                    color: AppTheme.blue,
                    onTap: () => context.push('/settings'),
                  ),
                  ProfileMenuItem(
                    icon: Icons.notifications_rounded,
                    label: 'Hoạt động',
                    color: AppTheme.secondary,
                    onTap: () {},
                  ),

                  const SizedBox(height: 28),

                  // ── Thành tựu header ───────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thành tựu',
                        style: TextStyle(
                          color: context.colors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                        ),
                        child: const Text(
                          'Xem tất cả',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Achievement card ───────────────────
                  ProfileAchievement(
                    currentStreak: streak.currentStreak,
                    longestStreak: streak.longestStreak,
                  ),

                  const SizedBox(height: 16),

                  // ── Lịch học ──────────────────────────
                  Text(
                    'Lịch học',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ProfileStreakCalendar(streak: streak),

                  const SizedBox(height: 28),

                  // ── Đăng xuất ─────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(authNotifierProvider.notifier).signOut(),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        'Đăng xuất',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade500,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar Section ─────────────────────────────────────────────────────────────
class _AvatarSection extends StatelessWidget {
  final String initial;
  final String displayName;
  final int totalDecks;
  final int totalCards;
  final int streakDays;

  const _AvatarSection({
    required this.initial,
    required this.displayName,
    required this.totalDecks,
    required this.totalCards,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar circle with gradient ring
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.tealGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          displayName,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatPill(
              value: '$totalDecks',
              label: 'Bộ thẻ',
              gradient: AppTheme.tealGradient,
            ),
            const SizedBox(width: 10),
            _StatPill(
              value: '$totalCards',
              label: 'Thẻ từ',
              gradient: AppTheme.primaryGradient,
            ),
            const SizedBox(width: 10),
            _StatPill(
              value: streakDays > 0 ? '🔥$streakDays' : '—',
              label: 'Ngày',
              gradient: AppTheme.yellowGradient,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final LinearGradient gradient;

  const _StatPill({
    required this.value,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── VIP Button ─────────────────────────────────────────────────────────────────
class _VipButton extends StatelessWidget {
  final VoidCallback onTap;
  const _VipButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppTheme.yellowGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Text(
          'Dùng thử miễn phí',
          style: TextStyle(
            color: Color(0xFF7C3E00),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
