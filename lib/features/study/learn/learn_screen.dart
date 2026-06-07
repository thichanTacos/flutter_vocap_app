import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/card_model.dart';
import '../../card/providers/card_provider.dart';
import 'widgets/fill_in.dart';
import 'widgets/learn_result.dart';
import 'widgets/multiple_choice.dart';
import 'providers/progress_provider.dart';
import '../../../core/services/audio_service.dart';

class LearnScreen extends ConsumerStatefulWidget {
  final String deckId;
  const LearnScreen({super.key, required this.deckId});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  static const int _batchSize = 5;
  late List<CardModel> _allCards;
  bool _initialized = false;

  int _batchStart = 0;

  // Batch hiện tại — chỉ chứa các thẻ CHƯA đúng
  List<CardModel> _pendingCards = [];

  // phase 0 = trắc nghiệm, phase 1 = điền từ
  int _phase = 0;
  int _indexInPhase = 0;

  // Trắc nghiệm
  int? _selectedAnswer;
  bool _answered = false;
  List<String> _cachedOptions = [];

  // Điền từ
  final _inputController = TextEditingController();
  FillState _fillState = FillState.none;

  // Tổng điểm
  int _correctCount = 0;
  int _wrongCount = 0;
  bool _showResult = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  // ── Init ─────────────────────────────────────────────
  void _initBatch() {
    final end = (_batchStart + _batchSize).clamp(0, _allCards.length);
    // Bắt đầu với tất cả thẻ trong batch
    _pendingCards = List<CardModel>.from(_allCards.sublist(_batchStart, end));
    _phase = 0;
    _indexInPhase = 0;
    _resetQuestion();
  }

  void _resetQuestion() {
    _selectedAnswer = null;
    _answered = false;
    _inputController.clear();
    _fillState = FillState.none;
    if (_pendingCards.isNotEmpty && _indexInPhase < _pendingCards.length) {
      if (_phase == 0) {
        _cachedOptions = _buildOptions(_pendingCards[_indexInPhase]);
      }
    }
  }

  List<String> _buildOptions(CardModel card) {
    final wrong = List<CardModel>.from(_allCards)
      ..removeWhere((c) => c.id == card.id)
      ..shuffle();
    return <String>[
      card.definition,
      ...wrong.take(3).map((c) => c.definition),
    ]..shuffle();
  }

  // ── Trắc nghiệm ──────────────────────────────────────
  void _onSelectAnswer(int index, CardModel card) {
    if (_answered) return;
    final isCorrect = _cachedOptions[index] == card.definition;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (isCorrect) {
        _correctCount++;
        ref.read(audioServiceProvider).playCorrect(); // ✅
      } else {
        _wrongCount++;
        ref.read(audioServiceProvider).playWrong(); // ✅
      }
    });
  }

  void _nextMultipleChoice(CardModel card) {
    final isCorrect = _cachedOptions[_selectedAnswer ?? 0] == card.definition;

    if (isCorrect) {
      setState(() {
        _pendingCards.removeAt(_indexInPhase);

        // ✅ Lưu progress ngay sau mỗi câu đúng
        final learnedSoFar = _batchStart +
            ((_batchStart + _batchSize).clamp(0, _allCards.length) -
                _batchStart -
                _pendingCards.length);
        _saveProgress(learnedSoFar);

        if (_pendingCards.isEmpty) {
          _phase = 1;
          final end = (_batchStart + _batchSize).clamp(0, _allCards.length);
          _pendingCards =
          List<CardModel>.from(_allCards.sublist(_batchStart, end));
          _indexInPhase = 0;
          _resetQuestion();
        } else {
          if (_indexInPhase >= _pendingCards.length) _indexInPhase = 0;
          _resetQuestion();
        }
      });
    } else {
      setState(() {
        _indexInPhase = (_indexInPhase + 1) % _pendingCards.length;
        _resetQuestion();
      });
    }
  }
  // ── Điền từ ──────────────────────────────────────────
  void _checkFill(CardModel card) {
    final input = _inputController.text.trim().toLowerCase();
    final correct = card.term.trim().toLowerCase();
    setState(() {
      _fillState = input == correct ? FillState.correct : FillState.wrong;
      if (_fillState == FillState.correct) {
        _correctCount++;
        ref.read(audioServiceProvider).playCorrect(); // ✅
      } else {
        _wrongCount++;
        ref.read(audioServiceProvider).playWrong(); // ✅
      }
    });
  }

  void _nextFillIn(CardModel card) {
    final isCorrect = _fillState == FillState.correct;

    if (isCorrect) {
      setState(() {
        _pendingCards.removeAt(_indexInPhase);

        // ✅ Lưu progress ngay sau mỗi câu đúng
        final batchSize =
            (_batchStart + _batchSize).clamp(0, _allCards.length) - _batchStart;
        final doneInBatch = batchSize - _pendingCards.length;
        final learnedSoFar = _batchStart + batchSize + doneInBatch;
        _saveProgress(learnedSoFar.clamp(0, _allCards.length));

        if (_pendingCards.isEmpty) {
          final nextStart = _batchStart + _batchSize;
          if (nextStart < _allCards.length) {
            _batchStart = nextStart;
            _initBatch();
          } else {
            // ✅ Hoàn thành tất cả
            _saveProgress(_allCards.length);
            _showResult = true;
          }
        } else {
          if (_indexInPhase >= _pendingCards.length) _indexInPhase = 0;
          _resetQuestion();
        }
      });
    } else {
      setState(() {
        _indexInPhase = (_indexInPhase + 1) % _pendingCards.length;
        _resetQuestion();
      });
    }
  }

// ✅ Hàm lưu progress
  void _saveProgress(int learnedCount) {
    ref.read(progressNotifierProvider.notifier).saveProgress(
      deckId: widget.deckId,
      learnedCount: learnedCount.clamp(0, _allCards.length),
      totalCount: _allCards.length,
    );
  }

  void _restart() {
    // Reset progress về 0
    ref.read(progressNotifierProvider.notifier).saveProgress(
      deckId: widget.deckId,
      learnedCount: 0,
      totalCount: _allCards.length,
    );
    setState(() {
      _allCards.shuffle();
      _batchStart = 0;
      _correctCount = 0;
      _wrongCount = 0;
      _showResult = false;
      _initBatch();
    });
  }

  // ── Progress ─────────────────────────────────────────
  // Tổng thẻ đã hoàn thành = số thẻ trước batch + thẻ đúng trong batch
  int get _progressDone {
    final batchSize =
        (_batchStart + _batchSize).clamp(0, _allCards.length) - _batchStart;
    final doneInBatch = batchSize - _pendingCards.length;
    // phase 1 cộng thêm batchSize vì phase 0 xong rồi
    final phaseBonus = _phase == 1 ? batchSize : 0;
    return _batchStart + phaseBonus + doneInBatch;
  }

  int get _progressTotal => _allCards.length * 2;

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(deckCardsProvider(widget.deckId));

    return cardsAsync.when(
      loading: () => Scaffold(
        backgroundColor: context.colors.bg,
        body:
        const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: context.colors.bg,
        body: Center(
            child: Text('Lỗi: $e',
                style: TextStyle(color: context.colors.textPrimary))),
      ),
      data: (cards) {
        if (!_initialized) {
          _allCards = List<CardModel>.from(cards)..shuffle();
          _initBatch();
          _initialized = true;
        }

        if (_showResult) return LearnResult(
          correctCount: _correctCount,
          wrongCount: _wrongCount,
          onRestart: _restart,
        );

        if (_pendingCards.isEmpty) return const SizedBox();

        final card = _pendingCards[_indexInPhase];

        return Scaffold(
          backgroundColor: context.colors.bg,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _CircleBadge(
                        value: _progressDone, color: AppTheme.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressTotal == 0
                              ? 0
                              : _progressDone / _progressTotal,
                          backgroundColor: context.colors.divider,
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(
                              AppTheme.green),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _CircleBadge(
                        value: _progressTotal, color: context.colors.textTertiary),
                  ],
                ),
              ),

              // Pending indicator
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    Icon(
                      _phase == 0
                          ? Icons.quiz_outlined
                          : Icons.edit_outlined,
                      color: context.colors.textTertiary,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _phase == 0
                          ? 'Trắc nghiệm · còn ${_pendingCards.length} thẻ cần đúng'
                          : 'Điền từ · còn ${_pendingCards.length} thẻ cần đúng',
                      style: TextStyle(
                          color: context.colors.textTertiary, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: _phase == 0
                    ? MultipleChoice(
                  card: card,
                  options: _cachedOptions,
                  selectedAnswer: _selectedAnswer,
                  answered: _answered,
                  onSelect: (i) => _onSelectAnswer(i, card),
                  onNext: () => _nextMultipleChoice(card),
                )
                    : FillIn(
                  card: card,
                  controller: _inputController,
                  fillState: _fillState,
                  onCheck: () => _checkFill(card),
                  onNext: () => _nextFillIn(card),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircleBadge extends StatelessWidget {
  final int value;
  final Color color;
  const _CircleBadge({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text('$value',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ),
    );
  }
}
