import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/ashbound_game.dart';
import '../widgets/joystick_widget.dart';

class HUDOverlay extends StatelessWidget {
  final ASHBOUNDGame game;

  const HUDOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final healthRatio = (game.player.currentHealth / game.playerStats.maxHealth)
        .clamp(0.0, 1.0);
    final emberRatio = (game.player.currentEmbers / game.playerStats.maxEmbers)
        .clamp(0.0, 1.0);

    return SafeArea(
      child: Stack(
        children: [
          // Top HUD Bar
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Health & Ember Bars
                Column(
                  crossAxisAlignment: CrossAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Health Bar
                    Container(
                      width: 200,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.red.shade900,
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: healthRatio,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "${game.player.currentHealth.toInt()} / ${game.playerStats.maxHealth.toInt()} HP",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Ember Bar
                    Container(
                      width: 160,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.orange.shade900,
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: emberRatio,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "🔥 ${game.player.currentEmbers} / ${game.playerStats.maxEmbers}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Room & Enemy Counters
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black80,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        game.currentRoom == 6
                            ? "ROOM 6: THE HOLLOW PYRE"
                            : "ROOM ${game.currentRoom} / ${game.totalRooms}",
                        style: TextStyle(
                          color: game.currentRoom == 6
                              ? Colors.redAccent
                              : Colors.amberAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Enemies: ${game.activeEnemies.length}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                // Pause Button
                IconButton(
                  icon: const Icon(
                    Icons.pause_circle_filled,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () {
                    game.state = GameState.paused;
                    game.overlays.add('Pause');
                    game.pauseEngine();
                  },
                ),
              ],
            ),
          ),

          // Bottom Left: Virtual Joystick
          Positioned(
            left: 24,
            bottom: 24,
            child: JoystickWidget(
              onChanged: (dir) => game.updateJoystickInput(dir),
              onReleased: () => game.updateJoystickInput(Vector2.zero()),
            ),
          ),

          // Bottom Right: Action Buttons (Attack, Dodge, Ember Burst)
          Positioned(
            right: 24,
            bottom: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Ember Burst Button
                if (game.playerStats.hasEmberBurst)
                  Padding(
                    padding: const EdgeInsets.only(right: 12, bottom: 20),
                    child: ElevatedButton(
                      onPressed: () => game.onEmberBurstPressed(),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        elevation: 6,
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department, size: 24),
                          Text(
                            "BURST",
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Dodge Button
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ElevatedButton(
                    onPressed: () => game.onDodgePressed(),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.blueGrey.shade800,
                      foregroundColor: Colors.amber,
                      elevation: 6,
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.run_circle, size: 28),
                        Text(
                          "ROLL",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Melee Attack Button
                ElevatedButton(
                  onPressed: () => game.onAttackPressed(),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(28),
                    backgroundColor: Colors.amber.shade800,
                    foregroundColor: Colors.white,
                    elevation: 8,
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sports_mma, size: 36),
                      Text(
                        "ATTACK",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
