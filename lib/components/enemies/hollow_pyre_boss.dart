import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../enemy.dart';
import '../player.dart';
import '../projectile.dart';
import '../visual_effects.dart';

enum BossState {
  idle,
  telegraphingNova,
  launchingNova,
  telegraphingBarrage,
  launchingBarrage,
}

class HollowPyreBoss extends Enemy {
  BossState state = BossState.idle;
  double stateTimer = 0.0;
  double actionCooldown = 2.0;

  int barrageCount = 0;
  double barrageTimer = 0.0;
  Vector2? targetPlayerPos;

  HollowPyreBoss({required Vector2 position})
    : super(
        type: EnemyType.boss,
        position: position,
        size: Vector2(70, 70),
        maxHealth: 500.0,
        moveSpeed: 40.0,
        damage: 20.0,
        emberDrop: 100,
      );

  bool get isPhase2 => currentHealth <= (maxHealth * 0.5);

  @override
  void updateAI(double dt, Player player) {
    if (isDead) return;

    if (actionCooldown > 0) {
      actionCooldown -= dt;
    }

    final toPlayer = player.position - position;
    final dist = toPlayer.length;

    switch (state) {
      case BossState.idle:
        // Slow tracking movement towards player center
        if (dist > 150) {
          position += toPlayer.normalized() * moveSpeed * dt;
        }

        if (actionCooldown <= 0) {
          final choice = Random().nextDouble();
          if (choice < 0.5) {
            // Telegraph Flame Nova
            state = BossState.telegraphingNova;
            stateTimer = isPhase2 ? 0.7 : 1.0;

            if (parent != null) {
              parent!.add(
                AttackTelegraphComponent.circle(
                  position: position.clone(),
                  radius: isPhase2 ? 220.0 : 160.0,
                  duration: stateTimer,
                ),
              );
            }
          } else {
            // Telegraph Fireball Barrage
            state = BossState.telegraphingBarrage;
            stateTimer = 0.8;
            targetPlayerPos = player.position.clone();
          }
        }
        break;

      case BossState.telegraphingNova:
        stateTimer -= dt;
        if (stateTimer <= 0) {
          state = BossState.launchingNova;
          _triggerFlameNova();
          actionCooldown = isPhase2 ? 1.8 : 2.5;
          state = BossState.idle;
        }
        break;

      case BossState.launchingNova:
        break;

      case BossState.telegraphingBarrage:
        stateTimer -= dt;
        if (stateTimer <= 0) {
          state = BossState.launchingBarrage;
          barrageCount = isPhase2 ? 8 : 5;
          barrageTimer = 0.0;
        }
        break;

      case BossState.launchingBarrage:
        barrageTimer -= dt;
        if (barrageTimer <= 0 && barrageCount > 0) {
          barrageCount--;
          barrageTimer = 0.12;

          if (parent != null) {
            final dir = (player.position - position).normalized();
            final spreadAngle = (Random().nextDouble() - 0.5) * 0.4;
            final rotatedDir = Vector2(
              dir.x * cos(spreadAngle) - dir.y * sin(spreadAngle),
              dir.x * sin(spreadAngle) + dir.y * cos(spreadAngle),
            );

            parent!.add(
              Projectile(
                position: position.clone(),
                velocity: rotatedDir * 240.0,
                damage: 15.0,
                color: Colors.deepOrangeAccent,
                radius: 8.0,
              ),
            );
          }
        }

        if (barrageCount <= 0) {
          actionCooldown = isPhase2 ? 1.5 : 2.2;
          state = BossState.idle;
        }
        break;
    }
  }

  void _triggerFlameNova() {
    if (parent == null) return;
    final projectileCount = isPhase2 ? 16 : 10;
    for (int i = 0; i < projectileCount; i++) {
      final angle = (i / projectileCount) * 2 * pi;
      final dir = Vector2(cos(angle), sin(angle));

      parent!.add(
        Projectile(
          position: position.clone(),
          velocity: dir * (isPhase2 ? 200.0 : 150.0),
          damage: 18.0,
          color: Colors.redAccent,
          radius: 9.0,
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (hitFlashTimer > 0) {
      canvas.drawCircle(Offset.zero, 35, Paint()..color = Colors.white);
      return;
    }

    // Outer aura glow
    final auraPaint = Paint()
      ..color = (isPhase2 ? Colors.redAccent : Colors.deepOrange).withOpacity(
        0.3,
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0);
    canvas.drawCircle(Offset.zero, 45, auraPaint);

    // Dark Ashen Boss Core
    final corePaint = Paint()..color = const Color(0xFF18181B);
    canvas.drawCircle(Offset.zero, 35, corePaint);

    final flamePaint = Paint()
      ..color = isPhase2 ? Colors.red : Colors.orangeAccent;
    canvas.drawCircle(Offset.zero, 24, flamePaint);

    final eyePaint = Paint()..color = Colors.amberAccent;
    canvas.drawCircle(const Offset(-8, -6), 5, eyePaint);
    canvas.drawCircle(const Offset(8, -6), 5, eyePaint);
  }
}
