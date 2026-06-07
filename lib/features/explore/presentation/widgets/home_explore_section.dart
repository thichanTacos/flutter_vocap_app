import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/vocab_repository.dart';
import '../../providers/explore_provider.dart';
import 'level_chip.dart';

class HomeExploreSection extends ConsumerWidget {
  const HomeExploreSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapAsync = ref.watch(levelDeckMapProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              const Text(
                'Khám phá theo cấp độ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              Text(
                'CEFR',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        mapAsync.when(
          loading: () => const SizedBox(
            height: 90,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3F3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Không thể tải từ vựng. Kiểm tra kết nối mạng.',
                      style: TextStyle(fontSize: 13, color: Colors.red[700]),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(levelDeckMapProvider),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
          data: (map) => SizedBox(
            height: 90,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: cefrLevels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final level = cefrLevels[i];
                final decks = map[level] ?? [];
                return LevelChip(
                  level: level,
                  deckCount: decks.length,
                  onTap: () => context.push('/explore/$level'),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
