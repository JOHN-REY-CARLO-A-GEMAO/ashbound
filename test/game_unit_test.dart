import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashbound/models/player_stats.dart';
import 'package:ashbound/services/progression_repository.dart';
import 'package:ashbound/systems/upgrade_system.dart';
import 'package:ashbound/systems/run_manager.dart';
import 'package:ashbound/systems/combat_system.dart';
import 'package:ashbound/components/player.dart';
import 'package:ashbound/components/enemy.dart';
import 'package:ashbound/components/enemies/ashling.dart';
import 'package:ashbound/components/enemies/hollow_pyre_boss.dart';
import 'package:flame/components.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlayerStats Tests', () {
    test('Initial base stats are correct', () {
      final stats = PlayerStats();
      expect(stats.maxHealth, equals(100.0));
      expect(stats.damage, equals(15.0));
      expect(stats.maxEmbers, equals(100));
      expect(stats.hasEmberBurst, isFalse);
    });

    test('Permanent upgrade application scales stats correctly', () {
      final stats = PlayerStats();
      stats.applyPermanentUpgrades(2, 3, 1); // +40 HP, +12 DMG, +25 Embers

      expect(stats.maxHealth, equals(140.0));
      expect(stats.damage, equals(27.0));
      expect(stats.maxEmbers, equals(125));
    });

    test('Temporary upgrade multipliers stack as expected', () {
      final stats = PlayerStats();
      stats.damageMultiplier += 0.25;
      stats.healthMultiplier += 0.30;

      expect(stats.damage, equals(18.75));
      expect(stats.maxHealth, equals(130.0));
    });
  });

  group('UpgradeSystem Tests', () {
    test('getRandomUpgrades returns requested count of unique choices', () {
      final rng = Random(42);
      final choices = UpgradeSystem.getRandomUpgrades(3, random: rng);

      expect(choices.length, equals(3));
      final types = choices.map((e) => e.type).toSet();
      expect(types.length, equals(3));
    });
  });

  group('RunManager Room Progression Tests', () {
    test('Room 1 spawns standard enemies', () {
      final manager = RunManager(seedRandom: Random(123));
      final enemies = manager.spawnEnemiesForRoom(1);

      expect(enemies.isNotEmpty, isTrue);
      expect(enemies.any((e) => e.type == EnemyType.ashling), isTrue);
      expect(enemies.any((e) => e.type == EnemyType.boss), isFalse);
    });

    test('Room 6 spawns The Hollow Pyre Boss exclusively', () {
      final manager = RunManager();
      final enemies = manager.spawnEnemiesForRoom(6);

      expect(enemies.length, equals(1));
      expect(enemies.first.type, equals(EnemyType.boss));
      expect(enemies.first, isA<HollowPyreBoss>());
    });
  });

  group('CombatSystem Single-Hit & Ember Burst Logic Tests', () {
    test('Melee attack processes exactly once per call', () {
      final stats = PlayerStats();
      final player = Player(stats: stats, position: Vector2(100, 100));
      final enemy = Ashling(position: Vector2(110, 100)); // Within 36 range

      expect(enemy.currentHealth, equals(40.0));

      // Execute attack callback once
      CombatSystem.processMeleeAttack(player: player, enemies: [enemy]);

      // Enemy takes exactly 15 damage (base damage)
      expect(enemy.currentHealth, equals(25.0));
    });

    test('Ember Burst unlock and upgrade increases radius and damage', () {
      final stats = PlayerStats();
      stats.hasEmberBurst = true;
      stats.emberBurstRadiusBonus = 40.0;
      stats.emberBurstDamageBonus = 20.0;

      final player = Player(stats: stats, position: Vector2(100, 100));
      player.currentEmbers = 50;

      final enemy = Ashling(position: Vector2(250, 100)); // Distance 150 (within 180+40=220 radius)

      expect(enemy.currentHealth, equals(40.0));
      CombatSystem.processEmberBurst(player: player, enemies: [enemy]);

      // Base burst damage = 15*2 + 20 = 50 -> kills Ashling (40 HP)
      expect(enemy.isDead, isTrue);
    });
  });

  group('ProgressionRepository Unit Tests', () {
    test('SharedPreferences purchase validation works correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = ProgressionRepository();
      await repo.load();

      expect(repo.embers, equals(0));
      expect(repo.buyHealthUpgrade(), isFalse);

      repo.addEmbers(100);
      expect(repo.embers, equals(100));

      final cost = repo.getHealthUpgradeCost();
      expect(repo.buyHealthUpgrade(), isTrue);
      expect(repo.embers, equals(100 - cost));
      expect(repo.healthLevel, equals(1));
    });
  });
}
