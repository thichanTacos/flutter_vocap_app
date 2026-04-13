import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/models/card_model.dart';
import '../../../../../shared/widgets/app_ink_well.dart';

class FlashcardResult extends StatelessWidget {
  final List<CardModel> known;
  final List<CardModel> unknown;
  final String deckId;
  final VoidCallback onContinueUnknown;
  final VoidCallback onRestart;

  const FlashcardResult({
    super.key,
    required this.known,
    required this.unknown,
    required this.deckId,
    required this.onContinueUnknown,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final total = known.length + unknown.length;
    final percent = total == 0 ? 0 : (known.length / total * 100).round();
    final isGood = percent >= 70;

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Kết quả',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary card with gradient
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isGood
                    ? AppTheme.greenGradient
                    : AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isGood ? AppTheme.green : AppTheme.primary)
                        .withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    isGood ? '🎉 Tuyệt vời!' : '💪 Cố lên!',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(
                          label: 'Biết rồi',
                          value: '${known.length}',
                          icon: Icons.check_circle_rounded,
                          color: Colors.white),
                      Container(
                          width: 1, height: 50, color: Colors.white38),
                      _Stat(
                          label: 'Chưa biết',
                          value: '${unknown.length}',
                          icon: Icons.close_rounded,
                          color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : known.length / total,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('$percent% đã biết',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            if (unknown.isNotEmpty)
              AppInkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onContinueUnknown,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Ôn lại thẻ chưa biết',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            AppInkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onRestart,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.dividerColor),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.replay_rounded, color: AppTheme.textMedium),
                    SizedBox(width: 8),
                    Text('Bắt đầu lại',
                        style: TextStyle(
                            color: AppTheme.textMedium,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            // Unknown cards list
            if (unknown.isNotEmpty) ...[
              const SizedBox(height: 28),
              Text('Cần ôn lại (${unknown.length})',
                  style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...unknown.map((card) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.red.shade100, width: 1),
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
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded,
                              color: Colors.red.shade400, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(card.term,
                                  style: const TextStyle(
                                      color: AppTheme.textDark,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(card.definition,
                                  style: const TextStyle(
                                      color: AppTheme.textMedium,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _Stat(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 30,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(
                color: color.withValues(alpha: 0.8), fontSize: 13)),
      ],
    );
  }
}
