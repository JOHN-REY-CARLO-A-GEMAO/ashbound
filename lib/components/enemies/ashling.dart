import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../enemy.dart';
import '../player.dart';

class Ashling extends Enemy {
  double attackCooldown = 0.0;
  final double attackRange = 28.0;

  Ashling({required Vector2 position})
    : super(
        type: EnemyType.ashling,
        position: position,
        size: Vector2(28, 28),
        maxHealth: 40.0,
        moveSpeed: 110.0,
        damage: 10.0,
        emberDrop: 5,
      );

  @override
  void updateAI(double dt, Player player) {
    if (isDead) return;

    if (attackCooldown > 0) {
      attackCooldown -= dt;
    }

    final toPlayer = player.position - position;
    final dist = toPlayer.length;

    if (dist > attackRange) {
      // Chase player
      final dir = toPlayer.normalized();
      position += dir * moveSpeed * dt;
    } else {
      // Attack player if cooldown ready
      if (attackCooldown <= 0) {
        attackCooldown = 1.2;
        player.takeDamage(damage);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (hitFlashTimer > 0) {
      canvas.drawCircle(Offset.zero, 14, Paint()..color = Colors.white);
      return;
    }

    // Fiery red/ash melee creature
    final bodyPaint = Paint()..color = const Color(0xFFDC2626);
    canvas.drawCircle(Offset.zero, 14, bodyPaint);

    final eyePaint = Paint()..color = Colors.yellowAccent;
    canvas.drawCircle(const Offset(4, -4), 3, eyePaint);
    canvas.drawCircle(const Offset(4, 4), 3, eyePaint);
  }
}
