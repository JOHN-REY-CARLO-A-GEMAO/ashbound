import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../enemy.dart';
import '../player.dart';
import '../visual_effects.dart';

class AshenBrute extends Enemy {
  double attackCooldown = 0.0;
  bool isTelegraphing = false;
  double telegraphTimer = 0.0;
  bool isCharging = false;
  Vector2 chargeDirection = Vector2.zero();
  double chargeTimer = 0.0;

  AshenBrute({required Vector2 position})
    : super(
        type: EnemyType.ashenBrute,
        position: position,
        size: Vector2(44, 44),
        maxHealth: 140.0,
        moveSpeed: 60.0,
        damage: 25.0,
        emberDrop: 15,
      );

  @override
  void updateAI(double dt, Player player) {
    if (isDead) return;

    if (attackCooldown > 0) {
      attackCooldown -= dt;
    }

    if (isTelegraphing) {
      telegraphTimer -= dt;
      if (telegraphTimer <= 0) {
        isTelegraphing = false;
        isCharging = true;
        chargeTimer = 0.5; // High speed charge duration
      }
      return;
    }

    if (isCharging) {
      chargeTimer -= dt;
      position += chargeDirection * (moveSpeed * 4.5) * dt;

      // Check collision with player while charging
      if ((player.position - position).length < 32) {
        player.takeDamage(damage);
        isCharging = false;
      }

      if (chargeTimer <= 0) {
        isCharging = false;
        attackCooldown = 2.5;
      }
      return;
    }

    final toPlayer = player.position - position;
    final dist = toPlayer.length;

    if (dist < 220 && attackCooldown <= 0) {
      // Start telegraphed charge attack
      isTelegraphing = true;
      telegraphTimer = 0.8;
      chargeDirection = toPlayer.normalized();

      if (parent != null) {
        parent!.add(
          AttackTelegraphComponent.circle(
            position: position.clone(),
            radius: 80.0,
            duration: 0.8,
          ),
        );
      }
    } else {
      // Slow chase
      position += toPlayer.normalized() * moveSpeed * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (hitFlashTimer > 0) {
      canvas.drawCircle(Offset.zero, 22, Paint()..color = Colors.white);
      return;
    }

    // Heavy Stone Brute
    final bodyPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawCircle(Offset.zero, 22, bodyPaint);

    final armorPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(-14, -14, 28, 28), armorPaint);

    final glowPaint = Paint()
      ..color = isTelegraphing ? Colors.red : Colors.orange;
    canvas.drawCircle(Offset.zero, 8, glowPaint);
  }
}
