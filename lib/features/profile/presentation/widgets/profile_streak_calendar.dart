import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../data/streak_model.dart';

class ProfileStreakCalendar extends StatelessWidget {
  final StreakModel streak;

  const ProfileStreakCalendar({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    const dayLabels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayLabels
                .map((d) => SizedBox(
                      width: 36,
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((day) {
              final isToday = day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;
              final isFuture = day.isAfter(now) && !isToday;
              final studied = streak.studiedOn(day);

              return SizedBox(
                width: 36,
                height: 36,
                child: isFuture
                    ? Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: context.colors.textTertiary,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : studied
                        ? Container(
                            decoration: BoxDecoration(
                              gradient: isToday
                                  ? const LinearGradient(
                                      colors: [
                                        AppTheme.primary,
                                        Color(0xFFFF8C42),
                                      ],
                                    )
                                  : null,
                              color: isToday
                                  ? null
                                  : AppTheme.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('🔥', style: TextStyle(fontSize: 16)),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              border: isToday
                                  ? Border.all(
                                      color: AppTheme.primary, width: 2)
                                  : null,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: isToday
                                      ? AppTheme.primary
                                      : context.colors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
              );
            }).toList(),
          ),
          if (streak.currentStreak > 0) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${streak.currentStreak} ngày liên tiếp',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (streak.longestStreak > streak.currentStreak) ...[
                  const SizedBox(width: 8),
                  Text(
                    '· Kỷ lục: ${streak.longestStreak} ngày',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
