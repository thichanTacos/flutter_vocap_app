import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/models/card_model.dart';
import 'feedback_bar.dart';

enum FillState { none, correct, wrong }

class FillIn extends StatelessWidget {
  final CardModel card;
  final TextEditingController controller;
  final FillState fillState;
  final VoidCallback onCheck;
  final VoidCallback onNext;

  const FillIn({
    super.key,
    required this.card,
    required this.controller,
    required this.fillState,
    required this.onCheck,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = fillState == FillState.correct
        ? AppTheme.green
        : fillState == FillState.wrong
            ? Colors.red.shade400
            : AppTheme.dividerColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Definition card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF2196F3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.definition,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhập thuật ngữ tương ứng',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Đáp án của bạn',
            style: TextStyle(
              color: AppTheme.textMedium,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: controller,
            enabled: fillState == FillState.none,
            autofocus: true,
            style: const TextStyle(color: AppTheme.textDark, fontSize: 16),
            onSubmitted: (_) {
              if (fillState == FillState.none) onCheck();
            },
            decoration: InputDecoration(
              hintText: 'Nhập đáp án...',
              hintStyle: const TextStyle(color: AppTheme.textMedium),
              filled: true,
              fillColor: AppTheme.cardBg,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 16),

          if (fillState == FillState.none) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCheck,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Kiểm tra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],

          if (fillState != FillState.none)
            FeedbackBar(
              isCorrect: fillState == FillState.correct,
              correctAnswer: card.term,
              onNext: onNext,
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
