import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/vocab_repository.dart';
import '../../providers/explore_provider.dart';

const _levelColors = {
  'a1': Color(0xFF22C55E),
  'a2': Color(0xFF4ECDC4),
  'b1': Color(0xFF3B82F6),
  'b2': Color(0xFFA855F7),
  'c1': Color(0xFFFF6B35),
  'c2': Color(0xFFF44336),
};

class VocabDeckScreen extends ConsumerStatefulWidget {
  final String level;
  final int deckIndex;
  const VocabDeckScreen({
    super.key,
    required this.level,
    required this.deckIndex,
  });

  @override
  ConsumerState<VocabDeckScreen> createState() => _VocabDeckScreenState();
}

class _VocabDeckScreenState extends ConsumerState<VocabDeckScreen> {
  bool _importing = false;
  String? _importedDeckId;

  Future<void> _importDeck() async {
    if (_importing || _importedDeckId != null) return;
    setState(() => _importing = true);

    try {
      // Dùng .future để await trực tiếp, type-safe
      final words = await ref.read(
        deckDefinitionsProvider((widget.level.toLowerCase(), widget.deckIndex)).future,
      );

      if (words.isEmpty) throw Exception('Không có từ nào để lưu');

      final deckId = await ref
          .read(vocabRepositoryProvider)
          .importDeckToLibrary(words, widget.level.toLowerCase(), widget.deckIndex);

      if (!mounted) return;
      setState(() {
        _importing = false;
        _importedDeckId = deckId;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã lưu vào thư viện!'),
          action: SnackBarAction(
            label: 'Xem',
            onPressed: () => context.push('/deck/$deckId'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _importing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _levelColors[widget.level.toLowerCase()] ?? const Color(0xFF3B82F6);
    final wordsAsync = ref.watch(
      deckDefinitionsProvider((widget.level.toLowerCase(), widget.deckIndex)),
    );
    final title = '${widget.level.toUpperCase()} – Deck ${widget.deckIndex + 1}';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            actions: [
              wordsAsync.maybeWhen(
                data: (_) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _importedDeckId != null
                      ? const Icon(Icons.check_circle_rounded, color: Colors.white)
                      : _importing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.bookmark_add_rounded),
                              tooltip: 'Lưu vào thư viện',
                              onPressed: _importDeck,
                            ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          wordsAsync.when(
            loading: () => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: color),
                    const SizedBox(height: 16),
                    const Text(
                      'Đang dịch sang tiếng Việt…',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Lần đầu có thể mất ~10 giây',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('Không thể tải định nghĩa'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(
                          deckDefinitionsProvider((widget.level.toLowerCase(), widget.deckIndex)),
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (words) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  if (i == words.length) {
                    return _BottomActions(
                      color: color,
                      imported: _importedDeckId != null,
                      importing: _importing,
                      deckId: _importedDeckId,
                      onImport: _importDeck,
                    );
                  }
                  final w = words[i];
                  return _WordTile(word: w, index: i, color: color);
                },
                childCount: words.length + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordTile extends StatelessWidget {
  final dynamic word;
  final int index;
  final Color color;

  const _WordTile({required this.word, required this.index, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.term,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  word.definition,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final Color color;
  final bool imported;
  final bool importing;
  final String? deckId;
  final VoidCallback onImport;

  const _BottomActions({
    required this.color,
    required this.imported,
    required this.importing,
    required this.deckId,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        children: [
          if (imported && deckId != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/deck/$deckId'),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Học ngay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: importing ? null : onImport,
                icon: importing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.bookmark_add_rounded),
                label: Text(importing ? 'Đang lưu…' : 'Lưu vào thư viện'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
