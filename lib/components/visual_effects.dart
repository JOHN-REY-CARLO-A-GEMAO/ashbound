import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class VisualEffects {
  // Paint cache for fast rendering
  static final Paint playerPaint = Paint()..color = const Color(0xFFFF6D00);
  static final Paint playerArmorPaint = Paint()
    ..color = const Color(0xFF3E2723);
  static final Paint ashlingPaint = Paint()..color = const Color(0xFFD50000);
  static final Paint cinderAdeptPaint = Paint()
    ..color = const Color(0xFFAA00FF);
  static final Paint ashenBrutePaint = Paint()..color = const Color(0xFF424242);
  static final Paint bossPaint = Paint()..color = const Color(0xFFFF3D00);
  static final Paint floorTilePaint = Paint()..color = const Color(0xFF1C1917);
  static final Paint floorGridPaint = Paint()
    ..color = const Color(0xFF292524)
    ..strokeWidth = 1.0;
  static final Paint wallPaint = Paint()..color = const Color(0xFF44403C);
}

class FloatingTextComponent extends PositionComponent {
  final String text;
  final Color color;
  final double duration;
  double _elapsed = 0.0;
  late TextPainter _textPainter;

  FloatingTextComponent({
    required this.text,
    required Vector2 position,
    required this.color,
    this.duration = 0.8,
  }) : super(position: position, size: Vector2(80, 30));

  @override
  Future<void> onLoad() async {
    _textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(blurRadius: 3, color: Colors.black, offset: Offset(1, 1)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position.y -= 25 * dt; // Float upwards
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final double opacity = (1.0 - (_elapsed / duration)).clamp(0.0, 1.0);
    canvas.save();
    canvas.translate(0, 0);
    _textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }
}

class EmberParticleComponent extends PositionComponent {
  final Vector2 velocity;
  final Color color;
  final double lifeSpan;
  final double radius;
  double _elapsed = 0.0;

  EmberParticleComponent({
    required Vector2 position,
    required this.velocity,
    required this.color,
    this.lifeSpan = 0.6,
    this.radius = 3.0,
  }) : super(position: position);

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position.add(velocity * dt);
    if (_elapsed >= lifeSpan) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final double progress = (_elapsed / lifeSpan).clamp(0.0, 1.0);
    final double alpha = (1.0 - progress);
    final paint = Paint()
      ..color = color.withOpacity(alpha)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, radius * (1.0 - progress * 0.5), paint);
  }
}

class AttackTelegraphComponent extends PositionComponent {
  final double duration;
  final double radius;
  final bool isCircle;
  final Vector2 rectSize;
  double _elapsed = 0.0;

  AttackTelegraphComponent.circle({
    required Vector2 position,
    required this.radius,
    required this.duration,
  }) : isCircle = true,
       rectSize = Vector2.zero(),
       super(position: position);

  AttackTelegraphComponent.rectangle({
    required Vector2 position,
    required Vector2 size,
    required this.duration,
  }) : isCircle = false,
       radius = 0,
       rectSize = size,
       super(position: position, size: size);

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final fillPaint = Paint()
      ..color = Colors.red.withOpacity(0.25 * progress)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (isCircle) {
      canvas.drawCircle(Offset.zero, radius * progress, fillPaint);
      canvas.drawCircle(Offset.zero, radius, borderPaint);
    } else {
      final rect = Rect.fromLTWH(
        -rectSize.x / 2,
        -rectSize.y / 2,
        rectSize.x,
        rectSize.y,
      );
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, borderPaint);
    }
  }
}
