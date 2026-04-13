import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/card_model.dart';
import '../../card/providers/card_provider.dart';

class MatchScreen extends ConsumerStatefulWidget {
  final String deckId;
  const MatchScreen({super.key, required this.deckId});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  List<_MatchItem> _items = [];
  int? _selectedIndex;
  int _matchedCount = 0;
  bool _initialized = false;
  Stopwatch _stopwatch = Stopwatch();
  bool _finished = false;

  void _initGame(List<CardModel> cards) {
    final limited = cards.take(6).toList();
    final terms = limited
        .map((c) => _MatchItem(id: c.id, text: c.term, type: _ItemType.term))
        .toList();
    final defs = limited
        .map((c) =>
        _MatchItem(id: c.id, text: c.definition, type: _ItemType.definition))
        .toList();
    _items = [...terms, ...defs]..shuffle();
    _stopwatch = Stopwatch()..start();
    _matchedCount = 0;
    _selectedIndex = null;
    _finished = false;
  }

  void _onTap(int index) {
    if (_items[index].isMatched) return;

    if (_selectedIndex == null) {
      setState(() => _selectedIndex = index);
      return;
    }

    if (_selectedIndex == index) {
      setState(() => _selectedIndex = null);
      return;
    }

    final first = _items[_selectedIndex!];
    final second = _items[index];

    if (first.id == second.id && first.type != second.type) {
      // Match!
      setState(() {
        _items[_selectedIndex!] = first.copyWith(isMatched: true);
        _items[index] = second.copyWith(isMatched: true);
        _selectedIndex = null;
        _matchedCount++;
        if (_matchedCount == _items.length ~/ 2) {
          _stopwatch.stop();
          _finished = true;
        }
      });
    } else {
      // Wrong — flash red briefly
      setState(() {
        _items[_selectedIndex!] = first.copyWith(isWrong: true);
        _items[index] = second.copyWith(isWrong: true);
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _items[_selectedIndex!] = first.copyWith(isWrong: false);
            _items[index] = second.copyWith(isWrong: false);
            _selectedIndex = null;
          });
        }
      });
    }
  }

  String _formatTime(int ms) {
    final seconds = ms ~/ 1000;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(deckCardsProvider(widget.deckId));

    return cardsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF1A1D28),
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFF1A1D28),
        body: Center(child: Text('Lỗi: $e')),
      ),
      data: (cards) {
        if (!_initialized) {
          _initGame(cards);
          _initialized = true;
        }

        if (_finished) return _buildFinished(cards);

        return Scaffold(
          backgroundColor: const Color(0xFF1A1D28),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A1D28),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: const Text('Ghép thẻ',
                style: TextStyle(color: Colors.white)),
            centerTitle: true,
            actions: [
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, _) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    _formatTime(_stopwatch.elapsedMilliseconds),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Progress
                LinearProgressIndicator(
                  value: _matchedCount / (_items.length ~/ 2),
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 4,
                ),
                const SizedBox(height: 16),
                Text(
                  '$_matchedCount / ${_items.length ~/ 2} cặp',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final isSelected = _selectedIndex == index;

                      Color bgColor = const Color(0xFF2A2D3E);
                      Color borderColor = Colors.transparent;

                      if (item.isMatched) {
                        bgColor = Colors.green.withOpacity(0.2);
                        borderColor = Colors.green;
                      } else if (item.isWrong) {
                        bgColor = Colors.red.withOpacity(0.2);
                        borderColor = Colors.red;
                      } else if (isSelected) {
                        bgColor = AppTheme.primary.withOpacity(0.2);
                        borderColor = AppTheme.primary;
                      }

                      return GestureDetector(
                        onTap: item.isMatched ? null : () => _onTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              item.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: item.isMatched
                                    ? Colors.green[300]
                                    : Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinished(List<CardModel> cards) {
    final seconds = _stopwatch.elapsedMilliseconds ~/ 1000;
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D28),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.celebration, color: Colors.amber, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Ghép xong! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D3E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.timer, color: AppTheme.primary, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(_stopwatch.elapsedMilliseconds),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold),
                    ),
                    Text('thời gian hoàn thành',
                        style: TextStyle(
                            color: Colors.grey[400], fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      seconds < 30
                          ? '⚡ Siêu nhanh!'
                          : seconds < 60
                          ? '👏 Tốt lắm!'
                          : '💪 Cố gắng hơn nhé!',
                      style: const TextStyle(
                          color: Colors.amber, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _initGame(cards);
                    _initialized = true;
                  });
                },
                icon: const Icon(Icons.refresh),
                label:
                const Text('Chơi lại', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Về trang bộ thẻ',
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchItem {
  final String id;
  final String text;
  final _ItemType type;
  final bool isMatched;
  final bool isWrong;

  _MatchItem({
    required this.id,
    required this.text,
    required this.type,
    this.isMatched = false,
    this.isWrong = false,
  });

  _MatchItem copyWith({bool? isMatched, bool? isWrong}) => _MatchItem(
    id: id,
    text: text,
    type: type,
    isMatched: isMatched ?? this.isMatched,
    isWrong: isWrong ?? this.isWrong,
  );
}

enum _ItemType { term, definition }