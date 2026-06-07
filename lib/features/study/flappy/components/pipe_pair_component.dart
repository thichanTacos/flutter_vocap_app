import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../flappy_game.dart';

class PipePairComponent extends PositionComponent
    with HasGameReference<FlappyGame> {
  final double screenHeight;
  final double groundHeight;
  final double gapCenter;
  final int cardIndex;

  bool _quizTriggered = false;

  PipePairComponent({
    required double startX,
    required this.screenHeight,
    required this.groundHeight,
    required this.gapCenter,
    required this.cardIndex,
  }) : super(
          position: Vector2(startX, 0),
          size: Vector2(FlappyGame.pipeWidth, 0),
        );

  @override
  Future<void> onLoad() async {
    const halfGap = FlappyGame.pipeGapSize / 2;
    final topHeight = gapCenter - halfGap;
    final bottomTop = gapCenter + halfGap;
    final bottomHeight = screenHeight - groundHeight - bottomTop;

    if (topHeight > 0) {
      add(_PipeRect(
        position: Vector2(0, 0),
        pipeSize: Vector2(FlappyGame.pipeWidth, topHeight),
        isTop: true,
      ));
    }
    if (bottomHeight > 0) {
      add(_PipeRect(
        position: Vector2(0, bottomTop),
        pipeSize: Vector2(FlappyGame.pipeWidth, bottomHeight),
        isTop: false,
      ));
    }
  }

  @override
  void update(double dt) {
    if (game.state != FlappyGameState.playing) return;

    position.x -= FlappyGame.pipeSpeed * dt;

    if (!_quizTriggered) {
      final birdX = game.bird.position.x;
      final pipeCenterX = position.x + FlappyGame.pipeWidth / 2;
      if (birdX >= pipeCenterX) {
        _quizTriggered = true;
        game.onPipePassed(cardIndex);
      }
    }

    if (position.x < -FlappyGame.pipeWidth - 20) {
      removeFromParent();
    }
  }
}

class _PipeRect extends PositionComponent {
  final bool isTop;
  final Vector2 pipeSize;

  _PipeRect({
    required Vector2 position,
    required this.pipeSize,
    required this.isTop,
  }) : super(position: position, size: pipeSize);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(
      size: pipeSize,
      collisionType: CollisionType.passive,
    ));
  }

  @override
  void render(Canvas canvas) {
    // Pipe body
    final bodyPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bodyPaint);

    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), borderPaint);

    // Vertical highlight
    final highlightPaint = Paint()..color = const Color(0xFF81C784).withValues(alpha: 0.5);
    canvas.drawRect(Rect.fromLTWH(6, 0, 10, size.y), highlightPaint);

    // Cap (wider piece at the opening end)
    final capPaint = Paint()..color = const Color(0xFF66BB6A);
    final capBorderPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    const capW = 16.0;
    const capH = 28.0;
    if (isTop) {
      canvas.drawRect(Rect.fromLTWH(-capW / 2, size.y - capH, size.x + capW, capH), capPaint);
      canvas.drawRect(Rect.fromLTWH(-capW / 2, size.y - capH, size.x + capW, capH), capBorderPaint);
    } else {
      canvas.drawRect(Rect.fromLTWH(-capW / 2, 0, size.x + capW, capH), capPaint);
      canvas.drawRect(Rect.fromLTWH(-capW / 2, 0, size.x + capW, capH), capBorderPaint);
    }
  }
}
