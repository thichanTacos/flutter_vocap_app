import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../../shared/models/card_model.dart';
import 'components/bird_component.dart';
import 'components/ground_component.dart';
import 'components/pipe_pair_component.dart';

enum FlappyGameState { waiting, playing, paused, quiz, gameOver, win }

class FlappyGame extends FlameGame with HasCollisionDetection {
  final List<CardModel> cards;

  FlappyGameState state = FlappyGameState.waiting;
  int currentPipeIndex = -1;
  int passedCount = 0;
  bool isWrongAnswer = false;
  CardModel? wrongAnswerCard;

  late BirdComponent bird;

  static const double gravity = 900;
  static const double jumpForce = -420;
  static const double pipeSpeed = 150;
  static const double pipeGapSize = 210;
  static const double pipeSpacing = 340;
  static const double pipeWidth = 70;
  static const double groundHeight = 80;

  FlappyGame({required this.cards});

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initGame();
  }

  void _initGame() {
    state = FlappyGameState.waiting;
    currentPipeIndex = -1;
    passedCount = 0;
    isWrongAnswer = false;
    wrongAnswerCard = null;

    add(GroundComponent(
      position: Vector2(0, size.y - groundHeight),
      groundWidth: size.x,
      groundHeight: groundHeight,
    ));

    bird = BirdComponent(
      startPosition: Vector2(size.x * 0.22, size.y * 0.45),
    );
    add(bird);

    final random = Random();
    final playableHeight = size.y - groundHeight;
    for (int i = 0; i < cards.length; i++) {
      final minCenter = playableHeight * 0.25;
      final maxCenter = playableHeight * 0.75;
      final gapCenter = minCenter + random.nextDouble() * (maxCenter - minCenter);
      add(PipePairComponent(
        startX: size.x + 80.0 + i * pipeSpacing,
        screenHeight: size.y,
        groundHeight: groundHeight,
        gapCenter: gapCenter,
        cardIndex: i,
      ));
    }

    overlays.add('start');
  }

  // Tap đầu tiên: bắt đầu game từ màn hình chờ
  void startGame() {
    if (state != FlappyGameState.waiting) return;
    state = FlappyGameState.playing;
    overlays.remove('start');
    bird.jump();
  }

  // Tap khi đang paused (sau khi trả lời đúng): resume physics, chim bắt đầu rơi
  void resumeFromPause() {
    if (state != FlappyGameState.paused) return;
    state = FlappyGameState.playing;
    overlays.remove('resumeHint');
    bird.resetVelocity(); // Reset về 0 để chim rơi từ từ, người chơi kịp phản ứng
  }

  // Tap khi đang playing: chim nhảy
  void handleTap() {
    if (state != FlappyGameState.playing) return;
    bird.jump();
  }

  void onPipePassed(int cardIndex) {
    if (state != FlappyGameState.playing) return;
    state = FlappyGameState.quiz;
    currentPipeIndex = cardIndex;
    overlays.add('quiz');
  }

  void onCorrectAnswer() {
    overlays.remove('quiz');
    passedCount++;
    if (passedCount >= cards.length) {
      state = FlappyGameState.win;
      overlays.add('win');
    } else {
      // Đóng băng chim, chờ tap để tiếp tục
      state = FlappyGameState.paused;
      overlays.add('resumeHint');
    }
  }

  void onWrongAnswer(CardModel card) {
    overlays.remove('quiz');
    wrongAnswerCard = card;
    isWrongAnswer = true;
    triggerGameOver();
  }

  void triggerGameOver() {
    if (state == FlappyGameState.gameOver) return;
    state = FlappyGameState.gameOver;
    overlays.remove('resumeHint');
    Future.delayed(const Duration(milliseconds: 600), () {
      if (state == FlappyGameState.gameOver) {
        overlays.add('gameOver');
      }
    });
  }

  void restartGame() {
    overlays.remove('gameOver');
    overlays.remove('win');
    overlays.remove('start');
    overlays.remove('quiz');
    overlays.remove('resumeHint');
    removeAll(children.toList());
    _initGame();
  }
}
