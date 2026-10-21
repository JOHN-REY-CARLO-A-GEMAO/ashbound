import 'package:flutter/material.dart';
import '../game/ashbound_game.dart';

class UpgradeSelectionOverlay extends StatelessWidget {
  final ASHBOUNDGame game;

  const UpgradeSelectionOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "ROOM CLEARED",
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Choose an expedition upgrade:",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: game.currentUpgradeChoices.map((upgrade) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                        color: const Color(0xFF18181B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.amber.shade700,
                            width: 1.5,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => game.selectUpgrade(upgrade),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  upgrade.iconSymbol,
                                  style: const TextStyle(fontSize: 36),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  upgrade.name,
                                  style: const TextStyle(
                                    color: Colors.amberAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  upgrade.description,
                                  style: const TextStyle(
                                    color: Colors.white87,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
