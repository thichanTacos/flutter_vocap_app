import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/models/card_model.dart';
import '../../../../../shared/widgets/app_ink_well.dart';
import 'feedback_bar.dart';

class MultipleChoice extends StatelessWidget {
  final CardModel card;
  final List<String> options;
  final int? selectedAnswer;
  final bool answered;
  final Function(int) onSelect;
  final VoidCallback onNext;

  const MultipleChoice({
    super.key,
    required this.card,
    required this.options,
    required this.selectedAnswer,
    required this.answered,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.term,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chọn định nghĩa đúng',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Options
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isCorrect = option == card.definition;
            final isSelected = selectedAnswer == index;

            Color bgColor = AppTheme.cardBg;
            Color borderColor = AppTheme.dividerColor;
            Color textColor = AppTheme.textDark;
            IconData? trailingIcon;

            if (answered) {
              if (isCorrect) {
                bgColor = const Color(0xFFDCFCE7);
                borderColor = AppTheme.green;
                textColor = AppTheme.green;
                trailingIcon = Icons.check_circle_rounded;
              } else if (isSelected && !isCorrect) {
                bgColor = Colors.red.shade50;
                borderColor = Colors.red.shade400;
                textColor = Colors.red.shade400;
                trailingIcon = Icons.cancel_rounded;
              }
            } else if (isSelected) {
              bgColor = AppTheme.primary.withValues(alpha: 0.08);
              borderColor = AppTheme.primary;
              textColor = AppTheme.primary;
            }

            return AppInkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: answered ? null : () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(option,
                          style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: isSelected || (answered && isCorrect)
                                  ? FontWeight.w600
                                  : FontWeight.normal)),
                    ),
                    if (trailingIcon != null)
                      Icon(trailingIcon, color: textColor, size: 20),
                  ],
                ),
              ),
            );
          }),

          if (answered)
            FeedbackBar(
              isCorrect: options[selectedAnswer ?? 0] == card.definition,
              correctAnswer: card.definition,
              onNext: onNext,
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
