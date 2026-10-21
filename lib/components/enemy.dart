import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player.dart';
import 'visual_effects.dart';

enum EnemyType { ashling, cinderAdept, ashenBrute, boss }

abstract class Enemy extends PositionComponent {
  final EnemyType type;
  double maxHealth;
  late double currentHealth;
  double moveSpeed;
  double damage;
  int emberDrop;

  bool isDead = false;
  double hitFlashTimer = 0.0;
  Vector2 knockbackVelocity = Vector2.zero();

  Enemy({
    required this.type,
    required Vector2 position,
    required Vector2 size,
    required this.maxHealth,
    required this.moveSpeed,
    required this.damage,
    required this.emberDrop,
  }) : super(position: position, size: size, anchor: Anchor.center) {
    currentHealth = maxHealth;
  }

  void takeDamage(double amount, {bool isCrit = false, Vector2? knockbackDir}) {
    if (isDead) return;

    currentHealth -= amount;
    hitFlashTimer = 0.15;

    if (knockbackDir != null && type != EnemyType.boss) {
      knockbackVelocity = knockbackDir.normalized() * 120.0;
    }

    if (parent != null) {
      parent!.add(
        FloatingTextComponent(
          text: "${isCrit ? 'CRIT! ' : ''}${amount.toInt()}",
          position: position.clone() + Vector2(-15, -25),
          color: isCrit ? Colors.amberAccent : Colors.white,
        ),
      );
    }

    if (currentHealth <= 0) {
      die();
    }
  }

  void die() {
    if (isDead) return;
    isDead = true;

    if (parent != null) {
      for (int i = 0; i < 8; i++) {
        final spread =
            Vector2(Random().nextDouble() - 0.5, Random().nextDouble() - 0.5) *
            60;
        parent!.add(
          EmberParticleComponent(
            position: position.clone() + spread,
            velocity: Vector2(
              (Random().nextDouble() - 0.5) * 80,
              (Random().nextDouble() - 0.5) * 80,
            ),
            color: Colors.deepOrange,
            lifeSpan: 0.5,
            radius: 4.0,
          ),
        );
      }
    }

    removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (hitFlashTimer > 0) {
      hitFlashTimer -= dt;
    }

    if (knockbackVelocity.lengthSq > 0) {
      position += knockbackVelocity * dt;
      knockbackVelocity *= max(0.0, 1.0 - 10.0 * dt); // Rapid decay
    }

    // World bounds safety clamp
    position.x = position.x.clamp(20.0, 1180.0);
    position.y = position.y.clamp(20.0, 780.0);
  }

  void updateAI(double dt, Player player);
}
