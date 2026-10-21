import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../enemy.dart';
import '../player.dart';
import '../projectile.dart';

class CinderAdept extends Enemy {
  double attackCooldown = 0.0;
  final double desiredDistance = 220.0;

  CinderAdept({required Vector2 position})
    : super(
        type: EnemyType.cinderAdept,
        position: position,
        size: Vector2(28, 28),
        maxHealth: 55.0,
        moveSpeed: 85.0,
        damage: 12.0,
        emberDrop: 8,
      );

  @override
  void updateAI(double dt, Player player) {
    if (isDead) return;

    if (attackCooldown > 0) {
      attackCooldown -= dt;
    }

    final toPlayer = player.position - position;
    final dist = toPlayer.length;

    // Maintain preferred ranged distance
    if (dist < desiredDistance - 40) {
      // Retreat
      final dir = -toPlayer.normalized();
      position += dir * moveSpeed * dt;
    } else if (dist > desiredDistance + 40) {
      // Advance
      final dir = toPlayer.normalized();
      position += dir * moveSpeed * dt;
    }

    // Fire projectile when cooldown ready
    if (attackCooldown <= 0 && dist < 350) {
      attackCooldown = 2.0;
      if (parent != null) {
        final projDir = toPlayer.normalized();
        parent!.add(
          Projectile(
            position: position.clone(),
            velocity: projDir * 180.0,
            damage: damage,
            color: Colors.purpleAccent,
          ),
        );
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

    // Dark Purple Cinder Adept Mage
    final robePaint = Paint()..color = const Color(0xFF7C3AED);
    canvas.drawCircle(Offset.zero, 14, robePaint);

    final hoodPaint = Paint()..color = const Color(0xFF4C1D95);
    canvas.drawCircle(Offset.zero, 8, hoodPaint);

    final orbPaint = Paint()..color = Colors.purpleAccent;
    canvas.drawCircle(const Offset(10, 0), 4, orbPaint);
  }
}
