import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/game_world.dart';
import '../components/player.dart';
import '../components/enemy.dart';
import '../components/projectile.dart';
import '../models/player_stats.dart';
import '../services/progression_repository.dart';
import '../systems/combat_system.dart';
import '../systems/run_manager.dart';
import '../systems/upgrade_system.dart';

enum GameState { titleMenu, playing, upgradeSelection, paused, gameOver, victory }

class ASHBOUNDGame extends FlameGame with HasGameRef {
  final ProgressionRepository progression;

  late GameWorld gameWorld;
  late Player player;
  late PlayerStats playerStats;
  late RunManager runManager;

  final List<Enemy> activeEnemies = [];
  GameState state = GameState.titleMenu;
  int currentRoom = 1;
  final int totalRooms = 6;

  List<UpgradeDefinition> currentUpgradeChoices = [];
  bool rewardClaimedForRoom = false;

  ASHBOUNDGame({required this.progression});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    runManager = RunManager();
    playerStats = PlayerStats();
    playerStats.applyPermanentUpgrades(
      progression.healthLevel,
      progression.damageLevel,
      progression.emberCapLevel,
    );

    gameWorld = GameWorld();
    add(gameWorld);

    player = Player(
      stats: playerStats,
      position: Vector2(600, 400),
    );
    add(player);

    player.onMeleeAttack = (pos, dir, dmg, range) {
      // Process attack ONCE per swing
      CombatSystem.processMeleeAttack(
        player: player,
        enemies: activeEnemies,
      );
    };

    player.onEmberBurst = (pos) {
      CombatSystem.processEmberBurst(
        player: player,
        enemies: activeEnemies,
      );
    };

    camera.viewfinder.anchor = Anchor.center;
    camera.follow(player);
  }

  void startNewRun() {
    for (final enemy in List<Enemy>.from(activeEnemies)) {
      enemy.removeFromParent();
    }
    activeEnemies.clear();

    for (final proj in children.whereType<Projectile>().toList()) {
      proj.removeFromParent();
    }

    playerStats.resetTemporaryModifiers();
    playerStats.applyPermanentUpgrades(
      progression.healthLevel,
      progression.damageLevel,
      progression.emberCapLevel,
    );

    player.currentHealth = playerStats.maxHealth;
    player.currentEmbers = 0;
    player.position = Vector2(600, 400);

    currentRoom = 1;
    rewardClaimedForRoom = false;
    _spawnRoomEnemies();

    state = GameState.playing;
    overlays.clear();
    overlays.add('HUD');
    resumeEngine();
  }

  void _spawnRoomEnemies() {
    activeEnemies.clear();
    final spawned = runManager.spawnEnemiesForRoom(currentRoom);
    for (final enemy in spawned) {
      activeEnemies.add(enemy);
      add(enemy);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (state != GameState.playing) return;

    // AI Updates
    for (final enemy in List<Enemy>.from(activeEnemies)) {
      if (enemy.isDead || enemy.parent == null) {
        activeEnemies.remove(enemy);
      } else {
        enemy.updateAI(dt, player);
      }
    }

    // Process Projectile hits on player
    CombatSystem.processProjectiles(
      player: player,
      projectiles: children.whereType<Projectile>().toList(),
    );

    // Check player death
    if (player.currentHealth <= 0) {
      _triggerGameOver();
      return;
    }

    // Check room completion
    if (activeEnemies.isEmpty && !rewardClaimedForRoom) {
      rewardClaimedForRoom = true;
      if (currentRoom < totalRooms) {
        _triggerUpgradeSelection();
      } else {
        _triggerVictory();
      }
    }
  }

  void _triggerUpgradeSelection() {
    state = GameState.upgradeSelection;
    currentUpgradeChoices = UpgradeSystem.getRandomUpgrades(3);
    overlays.add('UpgradeSelection');
    pauseEngine();
  }

  void selectUpgrade(UpgradeDefinition upgrade) {
    switch (upgrade.type) {
      case UpgradeType.swordDamage:
        playerStats.damageMultiplier += 0.25;
        break;
      case UpgradeType.maxHealth:
        playerStats.healthMultiplier += 0.30;
        player.heal(30);
        break;
      case UpgradeType.moveSpeed:
        playerStats.speedMultiplier += 0.20;
        break;
      case UpgradeType.dodgeCooldown:
        playerStats.dodgeCooldownReduction += 0.25;
        break;
      case UpgradeType.emberDash:
        playerStats.emberDashDamage += 15.0;
        break;
      case UpgradeType.critChance:
        playerStats.critChanceBonus += 0.15;
        playerStats.critMultiplierBonus += 0.25;
        break;
      case UpgradeType.healOnKill:
        playerStats.healOnKillAmount += 5.0;
        break;
      case UpgradeType.attackRange:
        playerStats.attackRangeBonus += 12.0;
        break;
      case UpgradeType.emberBurst:
        if (!playerStats.hasEmberBurst) {
          playerStats.hasEmberBurst = true;
        } else {
          playerStats.emberBurstRadiusBonus += 40.0;
          playerStats.emberBurstDamageBonus += 20.0;
        }
        break;
    }

    overlays.remove('UpgradeSelection');
    nextRoom();
  }

  void nextRoom() {
    currentRoom++;
    rewardClaimedForRoom = false;
    player.position = Vector2(600, 600);
    _spawnRoomEnemies();
    state = GameState.playing;
    resumeEngine();
  }

  void _triggerGameOver() {
    state = GameState.gameOver;
    progression.addEmbers(player.currentEmbers);
    overlays.clear();
    overlays.add('GameOver');
    pauseEngine();
  }

  void _triggerVictory() {
    state = GameState.victory;
    const bonus = 50;
    progression.addEmbers(player.currentEmbers + bonus);
    overlays.clear();
    overlays.add('Victory');
    pauseEngine();
  }

  void updateJoystickInput(Vector2 joystickDirection) {
    if (state == GameState.playing) {
      player.moveDirection = joystickDirection;
    } else {
      player.moveDirection = Vector2.zero();
    }
  }

  void onAttackPressed() {
    if (state == GameState.playing) {
      player.attack();
    }
  }

  void onDodgePressed() {
    if (state == GameState.playing) {
      player.dodge();
    }
  }

  void onEmberBurstPressed() {
    if (state == GameState.playing) {
      player.triggerEmberBurst();
    }
  }

  @override
  Color backgroundColor() => const Color(0xFF09090B);
}
