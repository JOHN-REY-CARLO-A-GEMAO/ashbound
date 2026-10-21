import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Projectile extends PositionComponent {
  final Vector2 velocity;
  final double damage;
  final bool isHostileToPlayer;
  final double lifeSpan;
  final Color color;
  final double radius;
  double _elapsed = 0.0;

  Projectile({
    required Vector2 position,
    required this.velocity,
    required this.damage,
    this.isHostileToPlayer = true,
    this.lifeSpan = 3.0,
    this.color = Colors.deepOrangeAccent,
    this.radius = 6.0,
  }) : super(
         position: position,
         size: Vector2.all(radius * 2),
         anchor: Anchor.center,
       );

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position += velocity * dt;

    if (_elapsed >= lifeSpan) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawCircle(Offset.zero, radius * 1.5, glowPaint);

    final corePaint = Paint()..color = color;
    canvas.drawCircle(Offset.zero, radius, corePaint);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset.zero, radius * 0.4, innerPaint);
  }
}
