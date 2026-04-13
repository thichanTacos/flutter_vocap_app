import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/models/deck_model.dart';
import '../../../../../shared/widgets/app_ink_well.dart';
import '../../../study/learn/providers/progress_provider.dart';

class ContinueCarousel extends ConsumerWidget {
  final List<DeckModel> decks;

  const ContinueCarousel({super.key, required this.decks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);
    final progressList = progressAsync.valueOrNull ?? [];

    final sorted = List<DeckModel>.from(decks)
      ..sort((a, b) {
        final pa = progressList.where((p) => p.deckId == a.id).firstOrNull;
        final pb = progressList.where((p) => p.deckId == b.id).firstOrNull;
        final percentA = pa?.percent ?? 0;
        final percentB = pb?.percent ?? 0;
        if (percentA == 0 && percentB > 0) return -1;
        if (percentB == 0 && percentA > 0) return 1;
        if (percentA >= 1 && percentB < 1) return 1;
        if (percentB >= 1 && percentA < 1) return -1;
        final timeA = pa?.lastStudied ?? DateTime(2000);
        final timeB = pb?.lastStudied ?? DateTime(2000);
        return timeB.compareTo(timeA);
      });

    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.92),
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final deck = sorted[index];
          final progress =
              progressList.where((p) => p.deckId == deck.id).firstOrNull;
          return _ContinueCard(deck: deck, progress: progress, index: index);
        },
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final DeckModel deck;
  final dynamic progress;
  final int index;

  const _ContinueCard({
    required this.deck,
    required this.index,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percent = progress?.percent ?? 0.0;
    final learnedCount = progress?.learnedCount ?? 0;
    final totalCount = deck.cardCount;
    final isCompleted = percent >= 1.0;
    final isNotStarted = learnedCount == 0;
    final gradient = AppTheme.deckGradients[index % AppTheme.deckGradients.length];

    String progressText;
    if (isNotStarted) {
      progressText = 'Chưa bắt đầu học';
    } else if (isCompleted) {
      progressText = 'Đã hoàn thành 🎉';
    } else {
      progressText = '$learnedCount / $totalCount thẻ · ${(percent * 100).round()}%';
    }

    final buttonText = isNotStarted ? 'Bắt đầu' : isCompleted ? 'Ôn lại' : 'Tiếp tục';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: AppInkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.push('/deck/${deck.id}'),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      deck.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalCount thẻ',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 7,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    progressText,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12),
                  ),
                  // Button
                  AppInkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.push('/deck/${deck.id}/learn'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          color: gradient.colors.first,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
