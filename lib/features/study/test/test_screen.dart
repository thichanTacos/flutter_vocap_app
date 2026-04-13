import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/card_model.dart';
import '../../card/providers/card_provider.dart';

class TestScreen extends ConsumerStatefulWidget {
  final String deckId;
  const TestScreen({super.key, required this.deckId});

  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen> {
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _correctCount = 0;
  late List<_Question> _questions;
  bool _initialized = false;
  bool _showResult = false;

  List<_Question> _generateQuestions(List<CardModel> cards) {
    final shuffled = List.from(cards)..shuffle();
    return shuffled.map((card) {
      final wrongOptions = List<CardModel>.from(cards)
        ..remove(card)
        ..shuffle();
      final options = [card, ...wrongOptions.take(3)]..shuffle();
      return _Question(
        card: card,
        options: options.map((c) => (c as CardModel).definition).toList(),
        correctAnswer: card.definition,
      );
    }).toList();
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (_questions[_currentIndex].options[index] ==
          _questions[_currentIndex].correctAnswer) {
        _correctCount++;
      }
    });
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      setState(() => _showResult = true);
    }
  }

  void _restart(List<CardModel> cards) {
    setState(() {
      _questions = _generateQuestions(cards);
      _currentIndex = 0;
      _correctCount = 0;
      _selectedAnswer = null;
      _answered = false;
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(deckCardsProvider(widget.deckId));

    return cardsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppTheme.lightBg,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppTheme.lightBg,
        body: Center(child: Text('Lỗi: $e')),
      ),
      data: (cards) {
        if (cards.length < 4) {
          return Scaffold(
            backgroundColor: AppTheme.lightBg,
            appBar: AppBar(
              backgroundColor: AppTheme.lightBg,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Text(
                'Cần ít nhất 4 thẻ để kiểm tra\n(hiện có ${cards.length} thẻ)',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMedium, fontSize: 16),
              ),
            ),
          );
        }

        if (!_initialized) {
          _questions = _generateQuestions(cards);
          _initialized = true;
        }

        if (_showResult) return _buildResult(cards);

        final question = _questions[_currentIndex];

        return Scaffold(
          backgroundColor: AppTheme.lightBg,
          appBar: AppBar(
            backgroundColor: AppTheme.lightBg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(
              '${_currentIndex + 1} / ${_questions.length}',
              style: const TextStyle(color: AppTheme.textDark),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                backgroundColor: Colors.grey[800],
                valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                minHeight: 3,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      // Câu hỏi
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text('Định nghĩa nào đúng với từ:',
                                style: TextStyle(
                                    color: AppTheme.textMedium, fontSize: 13)),
                            const SizedBox(height: 12),
                            Text(
                              question.card.term,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Options
                      ...question.options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        final isCorrect = option == question.correctAnswer;
                        final isSelected = _selectedAnswer == index;

                        Color bgColor = AppTheme.cardBg;
                        Color borderColor = Colors.transparent;

                        if (_answered) {
                          if (isCorrect) {
                            bgColor = Colors.green.withValues(alpha: 0.2);
                            borderColor = Colors.green;
                          } else if (isSelected && !isCorrect) {
                            bgColor = Colors.red.withValues(alpha: 0.2);
                            borderColor = Colors.red;
                          }
                        } else if (isSelected) {
                          borderColor = AppTheme.primary;
                        }

                        return GestureDetector(
                          onTap: () => _selectAnswer(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            child: Row(
                              children: [
                                // Letter badge
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isSelected && !_answered
                                        ? AppTheme.primary
                                        : Colors.grey[700],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      ['A', 'B', 'C', 'D'][index],
                                      style: const TextStyle(
                                          color: AppTheme.textDark,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(option,
                                      style: const TextStyle(
                                          color: AppTheme.textDark, fontSize: 15)),
                                ),
                                if (_answered)
                                  Icon(
                                    isCorrect
                                        ? Icons.check_circle
                                        : (isSelected ? Icons.cancel : null),
                                    color: isCorrect ? Colors.green : Colors.red,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),

                      const Spacer(),

                      if (_answered)
                        ElevatedButton(
                          onPressed: _next,
                          child: Text(
                            _currentIndex < _questions.length - 1
                                ? 'Câu tiếp theo →'
                                : 'Xem kết quả',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResult(List<CardModel> cards) {
    final total = _questions.length;
    final percent = (_correctCount / total * 100).round();

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                percent >= 70 ? Icons.emoji_events : Icons.refresh,
                color: percent >= 70 ? Colors.amber : Colors.orange,
                size: 80,
              ),
              const SizedBox(height: 16),
              Text(
                percent >= 70 ? 'Xuất sắc!' : 'Cần cố gắng hơn!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$percent%',
                      style: TextStyle(
                        color: percent >= 70 ? Colors.green : Colors.orange,
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ResultStat(
                            label: 'Đúng',
                            value: '$_correctCount',
                            color: Colors.green),
                        _ResultStat(
                            label: 'Sai',
                            value: '${total - _correctCount}',
                            color: Colors.red),
                        _ResultStat(
                            label: 'Tổng',
                            value: '$total',
                            color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _restart(cards),
                icon: const Icon(Icons.refresh),
                label:
                const Text('Làm lại', style: TextStyle(fontSize: 16)),
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

class _Question {
  final CardModel card;
  final List<String> options;
  final String correctAnswer;
  _Question(
      {required this.card,
        required this.options,
        required this.correctAnswer});
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ResultStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(color: AppTheme.textMedium, fontSize: 13)),
      ],
    );
  }
}