import 'package:flutter/material.dart';
import '../game/ashbound_game.dart';

class MainMenuOverlay extends StatelessWidget {
  final ASHBOUNDGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Stack(
        children: [
          // Background Embers styling
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [Color(0xFF271A12), Color(0xFF09090B)],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "ASHBOUND",
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 48,
                    fontWeight: FontWeight.black,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.deepOrangeAccent,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Echoes of the Last Flame",
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: 220,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      game.startNewRun();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade800,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "NEW EXPEDITION",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: 220,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      game.overlays.add('PermanentUpgrades');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27272A),
                      foregroundColor: Colors.amberAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "PERMANENT UPGRADES (🔥 ${game.progression.embers})",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: 220,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      game.overlays.add('Settings');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "SETTINGS",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
