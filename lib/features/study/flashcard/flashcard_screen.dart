import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/card_model.dart';
import '../../../shared/widgets/app_ink_well.dart';
import '../../card/providers/card_provider.dart';
import 'widgets/flashcard_progress.dart';
import 'widgets/flashcard_result.dart';
import 'widgets/swipe_card.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  final String deckId;
  const FlashcardScreen({super.key, required this.deckId});

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  int _currentIndex = 0;
  final List<CardModel> _known = [];
  final List<CardModel> _unknown = [];
  final List<bool> _history = [];
  late List<CardModel> _cards;
  bool _initialized = false;
  bool _finished = false;
  bool _isShuffled = false;

  void _init(List<CardModel> cards) {
    _cards = List<CardModel>.from(cards);
    _currentIndex = 0;
    _known.clear();
    _unknown.clear();
    _history.clear();
    _finished = false;
  }

  void _onSwipe(bool isKnown) {
    final card = _cards[_currentIndex];
    if (isKnown) {
      _known.add(card);
    } else {
      _unknown.add(card);
    }
    _history.add(isKnown);
    if (_currentIndex < _cards.length - 1) {
      setState(() => _currentIndex++);
    } else {
      setState(() => _finished = true);
    }
  }

  void _goBack() {
    if (_currentIndex == 0 || _history.isEmpty) return;
    final wasKnown = _history.removeLast();
    if (wasKnown) {
      _known.removeLast();
    } else {
      _unknown.removeLast();
    }
    setState(() => _currentIndex--);
  }

  void _restart(List<CardModel> allCards) {
    setState(() {
      _init(allCards);
      _isShuffled = false;
    });
  }

  void _continueWithUnknown() {
    if (_unknown.isEmpty) return;
    setState(() {
      _cards = List<CardModel>.from(_unknown);
      _currentIndex = 0;
      _known.clear();
      _unknown.clear();
      _history.clear();
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(deckCardsProvider(widget.deckId));
    return cardsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppTheme.lightBg,
        body: Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppTheme.lightBg,
        body: Center(
            child: Text('Lỗi: $e',
                style: const TextStyle(color: AppTheme.textDark))),
      ),
      data: (cards) {
        if (!_initialized) {
          _init(cards);
          _initialized = true;
        }
        if (_finished) {
          return FlashcardResult(
            known: List.from(_known),
            unknown: List.from(_unknown),
            deckId: widget.deckId,
            onContinueUnknown: _continueWithUnknown,
            onRestart: () => _restart(cards),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFFF5F0), // Nền cam rất nhạt
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, color: AppTheme.textDark),
              onPressed: () => context.pop(),
            ),
            title: Text(
              '${_currentIndex + 1} / ${_cards.length}',
              style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            actions: [
              AppInkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _isShuffled = !_isShuffled;
                    if (_isShuffled) {
                      _cards.shuffle();
                    } else {
                      _cards = List<CardModel>.from(cards);
                    }
                    _currentIndex = 0;
                    _known.clear();
                    _unknown.clear();
                    _history.clear();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isShuffled
                        ? AppTheme.primary.withValues(alpha: 0.1)
                        : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.shuffle_rounded,
                    color: _isShuffled
                        ? AppTheme.primary
                        : AppTheme.textMedium,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              FlashcardProgress(
                unknownCount: _unknown.length,
                knownCount: _known.length,
                current: _currentIndex,
                total: _cards.length,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SwipeCard(
                  key: ValueKey(_currentIndex),
                  card: _cards[_currentIndex],
                  onSwipeLeft: () => _onSwipe(false),
                  onSwipeRight: () => _onSwipe(true),
                ),
              ),
              // Bottom action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
                child: Row(
                  children: [
                    // Go back button
                    _ActionButton(
                      icon: Icons.undo_rounded,
                      color: _currentIndex > 0
                          ? AppTheme.textMedium
                          : AppTheme.dividerColor,
                      bgColor: AppTheme.surfaceColor,
                      onTap: _currentIndex > 0 ? _goBack : () {},
                    ),
                    const Spacer(),
                    // Unknown button
                    _ActionButton(
                      icon: Icons.close_rounded,
                      color: Colors.red.shade400,
                      bgColor: Colors.red.shade50,
                      label: 'Chưa biết',
                      onTap: () => _onSwipe(false),
                    ),
                    const SizedBox(width: 16),
                    // Known button
                    _ActionButton(
                      icon: Icons.check_rounded,
                      color: AppTheme.green,
                      bgColor: const Color(0xFFDCFCE7),
                      label: 'Biết rồi',
                      onTap: () => _onSwipe(true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String? label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
    this.label,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 80),
        reverseDuration: const Duration(milliseconds: 400));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: widget.label != null ? 60 : 46,
              height: widget.label != null ? 60 : 46,
              decoration: BoxDecoration(
                color: widget.bgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(widget.icon, color: widget.color,
                  size: widget.label != null ? 28 : 22),
            ),
            if (widget.label != null) ...[
              const SizedBox(height: 6),
              Text(widget.label!,
                  style: TextStyle(
                      color: widget.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}
