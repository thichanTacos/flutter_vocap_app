import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../deck/providers/deck_provider.dart';
import '../widgets/profile_avatar.dart';
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
    final totalCards =
        decks.fold<int>(0, (sum, d) => sum + d.cardCount);

    final email = user?.email ?? '';
    final displayName = user?.displayName ??
        (email.isNotEmpty ? email.split('@')[0] : 'Người dùng');
    final initial = displayName[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero gradient header
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.tealGradient,
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // AppBar row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined,
                                color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    // Avatar
                    ProfileAvatar(
                      initial: initial,
                      displayName: displayName,
                      email: email,
                    ),
                    const SizedBox(height: 24),
                    // Stats row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatChip(
                              value: '${decks.length}', label: 'Bộ thẻ'),
                          _divider(),
                          _StatChip(
                              value: '$totalCards', label: 'Tổng thẻ'),
                          _divider(),
                          const _StatChip(value: '🔥 7', label: 'Ngày'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu items
                  _SectionTitle('Cài đặt'),
                  const SizedBox(height: 8),
                  ProfileMenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Thông tin cá nhân',
                    color: AppTheme.primary,
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Thông báo',
                    badge: 4,
                    color: AppTheme.secondary,
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.palette_outlined,
                    label: 'Giao diện',
                    color: AppTheme.purple,
                    onTap: () {},
                  ),
                  ProfileMenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Trợ giúp',
                    color: AppTheme.blue,
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  // Thành tựu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionTitle('Thành tựu'),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Xem tất cả',
                            style: TextStyle(
                                color: AppTheme.primary, fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const ProfileAchievement(streakWeeks: 2),

                  const SizedBox(height: 16),

                  // Streak calendar
                  _SectionTitle('Lịch học'),
                  const SizedBox(height: 8),
                  const ProfileStreakCalendar(),

                  const SizedBox(height: 28),

                  // Đăng xuất
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(authNotifierProvider.notifier)
                            .signOut();
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Đăng xuất',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade500,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
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

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: Colors.white.withValues(alpha: 0.3),
      );
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold));
  }
}
