import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/explore_provider.dart';

const _levelColors = {
  'a1': Color(0xFF22C55E),
  'a2': Color(0xFF4ECDC4),
  'b1': Color(0xFF3B82F6),
  'b2': Color(0xFFA855F7),
  'c1': Color(0xFFFF6B35),
  'c2': Color(0xFFF44336),
};

const _levelDescriptions = {
  'a1': 'Người mới bắt đầu – Từ vựng cơ bản nhất',
  'a2': 'Sơ cấp – Giao tiếp hàng ngày đơn giản',
  'b1': 'Trung cấp – Hiểu các chủ đề quen thuộc',
  'b2': 'Trên trung cấp – Tranh luận và diễn đạt ý kiến',
  'c1': 'Nâng cao – Ngôn ngữ phức tạp và linh hoạt',
  'c2': 'Thành thạo – Gần như người bản ngữ',
};

class ExploreLevelScreen extends ConsumerWidget {
  final String level;
  const ExploreLevelScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapAsync = ref.watch(levelDeckMapProvider);
    final color = _levelColors[level.toLowerCase()] ?? const Color(0xFF3B82F6);
    final description = _levelDescriptions[level.toLowerCase()] ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Cấp độ ${level.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 52),
                    child: Text(
                      description,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),
          ),
          mapAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text('Không thể tải dữ liệu'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(levelDeckMapProvider),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
            data: (map) {
              final decks = map[level.toLowerCase()] ?? [];
              if (decks.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Không có deck nào.')),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final deck = decks[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        color: Colors.white,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            'Deck ${i + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${deck.terms.length} từ  •  ${level.toUpperCase()}',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: Color(0xFF9CA3AF)),
                          onTap: () => context.push(
                            '/explore/${level.toLowerCase()}/${deck.deckIndex}',
                          ),
                        ),
                      );
                    },
                    childCount: decks.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
