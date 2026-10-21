import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/player_stats.dart';
import 'visual_effects.dart';

class Player extends PositionComponent {
  final PlayerStats stats;
  late double currentHealth;
  int currentEmbers = 0;

  Vector2 moveDirection = Vector2.zero();
  Vector2 facingDirection = Vector2(1, 0);

  bool isAttacking = false;
  double _attackTimer = 0.0;

  bool isDodging = false;
  double _dodgeTimer = 0.0;
  double _dodgeCooldownTimer = 0.0;
  double _invulnerableTimer = 0.0;
  Vector2 _dodgeDirection = Vector2.zero();

  // Hit flash / visual state
  double _hitFlashTimer = 0.0;

  // Callback to signal attacks/abilities to combat system
  Function(Vector2 position, Vector2 direction, double damage, double range)?
  onMeleeAttack;
  Function(Vector2 position)? onEmberBurst;

  Player({required this.stats, required Vector2 position})
    : super(position: position, size: Vector2(32, 32), anchor: Anchor.center) {
    currentHealth = stats.maxHealth;
  }

  bool get isInvulnerable => isDodging || _invulnerableTimer > 0;

  @override
  void update(double dt) {
    super.update(dt);

    // Update timers
    if (_attackTimer > 0) {
      _attackTimer -= dt;
      if (_attackTimer <= 0) isAttacking = false;
    }

    if (_dodgeTimer > 0) {
      _dodgeTimer -= dt;
      if (_dodgeTimer <= 0) isDodging = false;
    }

    if (_dodgeCooldownTimer > 0) {
      _dodgeCooldownTimer -= dt;
    }

    if (_invulnerableTimer > 0) {
      _invulnerableTimer -= dt;
    }

    if (_hitFlashTimer > 0) {
      _hitFlashTimer -= dt;
    }

    // Movement handling
    if (isDodging) {
      final dodgeSpeed = stats.moveSpeed * 2.2;
      position += _dodgeDirection * dodgeSpeed * dt;
      // Spawn ember trail if upgraded
      if (stats.emberDashDamage > 0 && parent != null) {
        parent!.add(
          EmberParticleComponent(
            position: position.clone(),
            velocity: Vector2.zero(),
            color: Colors.orangeAccent,
            lifeSpan: 0.4,
            radius: 5.0,
          ),
        );
      }
    } else if (moveDirection.lengthSq > 0) {
      // Normalize diagonal movement speed
      final normalizedMove = moveDirection.normalized();
      position += normalizedMove * stats.moveSpeed * dt;
      facingDirection = normalizedMove.clone();
    }

    // World boundary clamping (Arena bounds 20..1180, 20..780)
    position.x = position.x.clamp(20.0, 1180.0);
    position.y = position.y.clamp(20.0, 780.0);
  }

  void attack() {
    if (isAttacking || isDodging) return;

    isAttacking = true;
    _attackTimer = stats.baseAttackCooldown;

    // Trigger attack callback for hit detection
    if (onMeleeAttack != null) {
      onMeleeAttack!(
        position.clone(),
        facingDirection.clone(),
        stats.damage,
        stats.attackRange,
      );
    }

    // Spawn slash particles
    if (parent != null) {
      final slashPos = position + facingDirection * (stats.attackRange * 0.6);
      for (int i = 0; i < 5; i++) {
        final spread =
            Vector2(Random().nextDouble() - 0.5, Random().nextDouble() - 0.5) *
            40;
        parent!.add(
          EmberParticleComponent(
            position: slashPos + spread,
            velocity: facingDirection * 100,
            color: Colors.amber,
            lifeSpan: 0.25,
            radius: 4.0,
          ),
        );
      }
    }
  }

  void dodge() {
    if (isDodging || _dodgeCooldownTimer > 0) return;

    isDodging = true;
    _dodgeTimer = 0.25; // Dodge duration
    _dodgeCooldownTimer = stats.dodgeCooldown;
    _invulnerableTimer = 0.35; // Invulnerability slightly exceeds roll duration

    _dodgeDirection = moveDirection.lengthSq > 0
        ? moveDirection.normalized()
        : facingDirection.clone();
  }

  bool triggerEmberBurst() {
    if (!stats.hasEmberBurst || currentEmbers < 30) return false;

    currentEmbers -= 30;
    if (onEmberBurst != null) {
      onEmberBurst!(position.clone());
    }

    // Visual burst particles
    if (parent != null) {
      for (int i = 0; i < 24; i++) {
        final angle = (i / 24) * 2 * pi;
        final dir = Vector2(cos(angle), sin(angle));
        parent!.add(
          EmberParticleComponent(
            position: position.clone(),
            velocity: dir * 250,
            color: Colors.deepOrange,
            lifeSpan: 0.5,
            radius: 6.0,
          ),
        );
      }
    }
    return true;
  }

  void takeDamage(double amount) {
    if (isInvulnerable) return;

    currentHealth = max(0.0, currentHealth - amount);
    _invulnerableTimer = 0.6; // Post-hit invulnerability
    _hitFlashTimer = 0.2;

    if (parent != null) {
      parent!.add(
        FloatingTextComponent(
          text: "-${amount.toInt()}",
          position: position.clone() + Vector2(-15, -30),
          color: Colors.redAccent,
        ),
      );
    }
  }

  void heal(double amount) {
    currentHealth = min(stats.maxHealth, currentHealth + amount);
    if (parent != null) {
      parent!.add(
        FloatingTextComponent(
          text: "+${amount.toInt()}",
          position: position.clone() + Vector2(-15, -30),
          color: Colors.greenAccent,
        ),
      );
    }
  }

  void addEmbers(int amount) {
    currentEmbers = min(stats.maxEmbers, currentEmbers + amount);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Hit flash / Invulnerability visual indication
    if (_hitFlashTimer > 0) {
      final flashPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset.zero, 16, flashPaint);
      return;
    }

    if (_invulnerableTimer > 0 &&
        (DateTime.now().millisecondsSinceEpoch ~/ 100) % 2 == 0) {
      // Blink effect during invulnerability
      return;
    }

    // Render Dark Fantasy Warrior Pixel Silhouette
    // Body / Cape
    final capePaint = Paint()..color = const Color(0xFF1E1B4B);
    canvas.drawCircle(Offset.zero, 16, capePaint);

    // Armor / Core
    final armorPaint = Paint()..color = const Color(0xFFB45309);
    canvas.drawCircle(Offset.zero, 12, armorPaint);

    // Glowing Flame Core
    final flameCorePaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset.zero, 6, flameCorePaint);

    // Facing Direction / Sword indicator
    final angle = atan2(facingDirection.y, facingDirection.x);
    canvas.save();
    canvas.rotate(angle);

    final swordPaint = Paint()
      ..color = Colors.orangeAccent
      ..strokeWidth = 4.0;
    canvas.drawLine(const Offset(8, 0), const Offset(24, 0), swordPaint);

    // Attack Swing visual Arc
    if (isAttacking) {
      final attackArcPaint = Paint()
        ..color = Colors.amber.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0;
      final arcRect = Rect.fromCircle(
        center: Offset.zero,
        radius: stats.attackRange,
      );
      canvas.drawArc(arcRect, -pi / 3, (2 * pi) / 3, false, attackArcPaint);
    }

    canvas.restore();
  }
}
