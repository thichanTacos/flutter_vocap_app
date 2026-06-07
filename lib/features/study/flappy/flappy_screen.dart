import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/card/providers/card_provider.dart';
import 'flappy_game.dart';
import 'overlays/game_over_overlay.dart';
import 'overlays/quiz_overlay.dart';
import 'overlays/win_overlay.dart';

class FlappyScreen extends ConsumerStatefulWidget {
  final String deckId;
  const FlappyScreen({super.key, required this.deckId});

  @override
  ConsumerState<FlappyScreen> createState() => _FlappyScreenState();
}

class _FlappyScreenState extends ConsumerState<FlappyScreen> {
  FlappyGame? _game;

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(deckCardsProvider(widget.deckId));

    return Scaffold(
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (cards) {
          if (cards.length < 2) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 56, color: Color(0xFFFFA000)),
                    const SizedBox(height: 16),
                    const Text(
                      'Cần ít nhất 2 từ để chơi game',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Quay lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          _game ??= FlappyGame(cards: List.from(cards));

          // GestureDetector bên ngoài xử lý mọi tap thay cho Flame TapCallbacks
          // - waiting: startGame()
          // - playing: handleTap() (nhảy hoặc dismiss resumeHint)
          // - quiz/gameOver/win: overlay tự xử lý, handleTap/startGame đều guard bằng state
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final game = _game;
              if (game == null) return;
              if (game.state == FlappyGameState.waiting) {
                game.startGame();
              } else if (game.state == FlappyGameState.paused) {
                game.resumeFromPause(); // tap 1: chim bắt đầu rơi
              } else if (game.state == FlappyGameState.playing) {
                game.handleTap(); // tap 2+: chim nhảy
              }
            },
            child: GameWidget<FlappyGame>(
              game: _game!,
              overlayBuilderMap: {
                'start': (context, game) => _StartOverlay(game: game),
                'quiz': (context, game) => QuizOverlay(game: game),
                'gameOver': (context, game) => GameOverOverlay(game: game),
                'win': (context, game) => WinOverlay(game: game),
                'resumeHint': (_, __) => const _ResumeHintOverlay(),
              },
            ),
          );
        },
      ),
    );
  }
}

class _StartOverlay extends StatelessWidget {
  final FlappyGame game;
  const _StartOverlay({required this.game});

  @override
  Widget build(BuildContext context) {
    // Không cần GestureDetector riêng — outer GestureDetector trong FlappyScreen xử lý
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🐦', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 6),
              const Text(
                'Flappy Bird',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${game.cards.length} từ vựng',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _rule(Icons.touch_app_rounded, 'Chạm màn hình để nhảy'),
              const SizedBox(height: 6),
              _rule(Icons.question_answer_rounded, 'Qua cột → trả lời câu hỏi'),
              _rule(Icons.close_rounded, 'Sai → Game Over'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Chạm để bắt đầu!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rule(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          ],
        ),
      );
}

// IgnorePointer để tap xuyên qua hint, outer GestureDetector sẽ nhận và dismiss
class _ResumeHintOverlay extends StatelessWidget {
  const _ResumeHintOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 72),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chạm để tiếp tục',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Chim sẽ rơi — lần tiếp theo mới nhảy!',
                style: TextStyle(color: Color(0xFFB3D9FF), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
