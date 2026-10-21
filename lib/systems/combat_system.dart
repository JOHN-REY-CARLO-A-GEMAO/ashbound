import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../components/enemy.dart';
import '../components/player.dart';
import '../components/projectile.dart';

class CombatSystem {
  /// Executed exactly ONCE per melee swing when onMeleeAttack fires
  static void processMeleeAttack({
    required Player player,
    required List<Enemy> enemies,
  }) {
    final attackPos = player.position + player.facingDirection * (player.stats.attackRange * 0.5);
    final range = player.stats.attackRange;

    for (final enemy in List<Enemy>.from(enemies)) {
      if (enemy.isDead) continue;
      final dist = (enemy.position - attackPos).length;
      if (dist <= range + enemy.size.x / 2) {
        final isCrit = Random().nextDouble() < player.stats.critChance;
        final dmg = isCrit ? player.stats.damage * player.stats.critMultiplier : player.stats.damage;

        final knockbackDir = enemy.position - player.position;
        enemy.takeDamage(dmg, isCrit: isCrit, knockbackDir: knockbackDir);

        if (enemy.isDead) {
          player.addEmbers(enemy.emberDrop);
          if (player.stats.healOnKillAmount > 0) {
            player.heal(player.stats.healOnKillAmount);
          }
        }
      }
    }
  }

  /// Executed every frame to handle projectile hits on player
  static void processProjectiles({
    required Player player,
    required List<Projectile> projectiles,
  }) {
    for (final projectile in List<Projectile>.from(projectiles)) {
      if (projectile.isHostileToPlayer && !player.isInvulnerable) {
        final dist = (player.position - projectile.position).length;
        if (dist < player.size.x / 2 + projectile.radius) {
          player.takeDamage(projectile.damage);
          projectile.removeFromParent();
        }
      }
    }
  }

  /// Executed when Ember Burst ability is triggered
  static void processEmberBurst({
    required Player player,
    required List<Enemy> enemies,
  }) {
    final double burstRadius = 180.0 + player.stats.emberBurstRadiusBonus;
    final double dmg = (player.stats.damage * 2.0) + player.stats.emberBurstDamageBonus;

    for (final enemy in List<Enemy>.from(enemies)) {
      if (enemy.isDead) continue;
      final dist = (enemy.position - player.position).length;
      if (dist <= burstRadius) {
        final knockbackDir = enemy.position - player.position;
        enemy.takeDamage(dmg, isCrit: true, knockbackDir: knockbackDir);

        if (enemy.isDead) {
          player.addEmbers(enemy.emberDrop);
          if (player.stats.healOnKillAmount > 0) {
            player.heal(player.stats.healOnKillAmount);
          }
        }
      }
    }
  }
}
