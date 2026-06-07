import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../flappy_game.dart';

class BirdComponent extends PositionComponent
    with HasGameReference<FlappyGame>, CollisionCallbacks {
  final Vector2 startPosition;
  double _velocity = 0;

  BirdComponent({required this.startPosition})
      : super(size: Vector2(46, 46), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    position = startPosition;
    add(RectangleHitbox(
      size: Vector2(34, 34),
      position: Vector2(6, 6),
      collisionType: CollisionType.active,
    ));
  }

  @override
  void render(Canvas canvas) {
    // Body
    final bodyPaint = Paint()..color = const Color(0xFFFFC107);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, size.x - 4, size.y - 4),
        const Radius.circular(10),
      ),
      bodyPaint,
    );
    // Belly
    final bellyPaint = Paint()..color = const Color(0xFFFFE082);
    canvas.drawOval(
      Rect.fromLTWH(size.x * 0.1, size.y * 0.45, size.x * 0.55, size.y * 0.45),
      bellyPaint,
    );
    // Eye white
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.x * 0.68, size.y * 0.32), 7, eyePaint);
    // Pupil
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(size.x * 0.71, size.y * 0.34), 3.5, pupilPaint);
    // Beak
    final beakPaint = Paint()..color = const Color(0xFFFF6F00);
    final beakPath = Path()
      ..moveTo(size.x - 2, size.y * 0.45)
      ..lineTo(size.x + 10, size.y * 0.53)
      ..lineTo(size.x - 2, size.y * 0.61)
      ..close();
    canvas.drawPath(beakPath, beakPaint);
    // Wing
    final wingPaint = Paint()..color = const Color(0xFFFFB300);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, size.y * 0.52, 20, 12),
        const Radius.circular(6),
      ),
      wingPaint,
    );
  }

  void jump() {
    _velocity = FlappyGame.jumpForce;
  }

  void resetVelocity() {
    _velocity = 0;
  }

  @override
  void update(double dt) {
    if (game.state == FlappyGameState.playing || game.state == FlappyGameState.gameOver) {
      _velocity += FlappyGame.gravity * dt;
      position.y += _velocity * dt;
      angle = (_velocity / 1500).clamp(-pi / 4, pi / 2);

      if (game.state == FlappyGameState.playing && position.y < -size.y) {
        game.triggerGameOver();
      }
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (game.state == FlappyGameState.playing) {
      game.triggerGameOver();
    }
  }
}
