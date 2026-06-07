import 'package:flutter/material.dart';
import '../../../../shared/models/card_model.dart';
import '../flappy_game.dart';

class QuizOverlay extends StatefulWidget {
  final FlappyGame game;
  const QuizOverlay({super.key, required this.game});

  @override
  State<QuizOverlay> createState() => _QuizOverlayState();
}

class _QuizOverlayState extends State<QuizOverlay> {
  int? _selectedIndex;
  bool _confirmed = false;
  late List<String> _options;
  late CardModel _card;

  @override
  void initState() {
    super.initState();
    _card = widget.game.cards[widget.game.currentPipeIndex];
    _buildOptions();
  }

  void _buildOptions() {
    final correct = _card.term;
    final others = widget.game.cards
        .where((c) => c.id != _card.id)
        .toList()
      ..shuffle();
    final wrongs = others.take(3).map((c) => c.term).toList();
    _options = [correct, ...wrongs]..shuffle();
  }

  void _onSelect(int index) {
    if (_confirmed) return;
    setState(() => _selectedIndex = index);
  }

  void _onConfirm() {
    if (_selectedIndex == null || _confirmed) return;
    setState(() => _confirmed = true);

    final isCorrect = _options[_selectedIndex!] == _card.term;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (isCorrect) {
        widget.game.onCorrectAnswer();
      } else {
        widget.game.onWrongAnswer(_card);
      }
    });
  }

  Color _optionBg(int index) {
    if (_selectedIndex == null) return const Color(0xFFF3F4F6);
    if (!_confirmed) {
      return index == _selectedIndex ? const Color(0xFF3B82F6) : const Color(0xFFF3F4F6);
    }
    // Sau khi confirm: hiện màu đúng/sai
    if (index == _selectedIndex) {
      return _options[index] == _card.term ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    }
    if (_options[index] == _card.term) return const Color(0xFF4CAF50);
    return const Color(0xFFF3F4F6);
  }

  bool _isTextWhite(int index) {
    if (_selectedIndex == null) return false;
    if (!_confirmed) return index == _selectedIndex;
    return index == _selectedIndex || _options[index] == _card.term;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.game.cards.length;
    final current = widget.game.currentPipeIndex + 1;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFC107), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Cột $current / $total',
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Từ tiếng Anh nào có nghĩa là?',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E7FF)),
                ),
                child: Text(
                  _card.definition,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 14),
              // Các đáp án — chỉ chọn, chưa check
              ...List.generate(_options.length, (i) {
                return GestureDetector(
                  onTap: () => _onSelect(i),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _optionBg(i),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !_confirmed && _selectedIndex == i
                            ? const Color(0xFF3B82F6)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      _options[i],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _isTextWhite(i) ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 6),
              // Nút xác nhận
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_selectedIndex != null && !_confirmed) ? _onConfirm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    disabledBackgroundColor: const Color(0xFFD1D5DB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _confirmed ? 'Đang xử lý...' : 'Xác nhận',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
