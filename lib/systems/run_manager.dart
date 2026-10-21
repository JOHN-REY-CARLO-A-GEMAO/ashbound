import 'dart:math';
import 'package:flame/components.dart';
import '../components/enemy.dart';
import '../components/enemies/ashling.dart';
import '../components/enemies/cinder_adept.dart';
import '../components/enemies/ashen_brute.dart';
import '../components/enemies/hollow_pyre_boss.dart';

class RunManager {
  final Random random;

  RunManager({Random? seedRandom}) : random = seedRandom ?? Random();

  List<Enemy> spawnEnemiesForRoom(int roomNumber) {
    final List<Enemy> enemies = [];

    if (roomNumber >= 6) {
      // Room 6: The Hollow Pyre Boss
      enemies.add(HollowPyreBoss(position: Vector2(600, 300)));
      return enemies;
    }

    // Rooms 1-5: Wave Scaling
    final int baseCount = 3 + roomNumber * 2;
    for (int i = 0; i < baseCount; i++) {
      // Spawn around outer arena
      final double angle = random.nextDouble() * 2 * pi;
      final double distance = 250 + random.nextDouble() * 250;
      final pos = Vector2(
        600 + cos(angle) * distance,
        400 + sin(angle) * distance,
      );

      // Clamp spawn inside arena bounds
      pos.x = pos.x.clamp(80.0, 1120.0);
      pos.y = pos.y.clamp(80.0, 720.0);

      final double roll = random.nextDouble();
      if (roomNumber == 1) {
        // Room 1: Mostly Ashlings
        if (roll < 0.8) {
          enemies.add(Ashling(position: pos));
        } else {
          enemies.add(CinderAdept(position: pos));
        }
      } else if (roomNumber <= 3) {
        if (roll < 0.5) {
          enemies.add(Ashling(position: pos));
        } else if (roll < 0.85) {
          enemies.add(CinderAdept(position: pos));
        } else {
          enemies.add(AshenBrute(position: pos));
        }
      } else {
        // Rooms 4-5: Harder composition
        if (roll < 0.35) {
          enemies.add(Ashling(position: pos));
        } else if (roll < 0.70) {
          enemies.add(CinderAdept(position: pos));
        } else {
          enemies.add(AshenBrute(position: pos));
        }
      }
    }

    return enemies;
  }
}
