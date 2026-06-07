import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GroundComponent extends PositionComponent {
  final double groundWidth;
  final double groundHeight;

  GroundComponent({
    required Vector2 position,
    required this.groundWidth,
    required this.groundHeight,
  }) : super(position: position, size: Vector2(groundWidth, groundHeight));

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(
      size: size,
      collisionType: CollisionType.passive,
    ));
  }

  @override
  void render(Canvas canvas) {
    // Grass strip
    final grassPaint = Paint()..color = const Color(0xFF8BC34A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 20), grassPaint);
    // Dirt
    final dirtPaint = Paint()..color = const Color(0xFFD2B48C);
    canvas.drawRect(Rect.fromLTWH(0, 20, size.x, size.y - 20), dirtPaint);
    // Top border line
    final borderPaint = Paint()
      ..color = const Color(0xFF689F38)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.x, 0), borderPaint);
  }
}
