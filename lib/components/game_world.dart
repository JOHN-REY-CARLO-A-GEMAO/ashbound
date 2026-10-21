import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameWorld extends PositionComponent {
  final double worldWidth;
  final double worldHeight;

  GameWorld({this.worldWidth = 1200.0, this.worldHeight = 800.0})
    : super(size: Vector2(worldWidth, worldHeight));

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render dark stone floor tiles
    final floorPaint = Paint()..color = const Color(0xFF18181B);
    final gridPaint = Paint()
      ..color = const Color(0xFF27272A)
      ..strokeWidth = 2.0;

    canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, worldHeight), floorPaint);

    const double tileSize = 60.0;
    for (double x = 0; x < worldWidth; x += tileSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, worldHeight), gridPaint);
    }
    for (double y = 0; y < worldHeight; y += tileSize) {
      canvas.drawLine(Offset(0, y), Offset(worldWidth, y), gridPaint);
    }

    // Outer wall boundary visuals
    final wallPaint = Paint()
      ..color = const Color(0xFFE11D48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    canvas.drawRect(Rect.fromLTWH(0, 0, worldWidth, worldHeight), wallPaint);

    // Decorative glowing ember spots in corners/arena
    final emberGlow = Paint()
      ..color = const Color(0xFFFF5722).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0);

    canvas.drawCircle(
      Offset(worldWidth * 0.2, worldHeight * 0.2),
      80,
      emberGlow,
    );
    canvas.drawCircle(
      Offset(worldWidth * 0.8, worldHeight * 0.2),
      80,
      emberGlow,
    );
    canvas.drawCircle(
      Offset(worldWidth * 0.2, worldHeight * 0.8),
      80,
      emberGlow,
    );
    canvas.drawCircle(
      Offset(worldWidth * 0.8, worldHeight * 0.8),
      80,
      emberGlow,
    );
    canvas.drawCircle(
      Offset(worldWidth * 0.5, worldHeight * 0.5),
      120,
      emberGlow,
    );
  }
}
