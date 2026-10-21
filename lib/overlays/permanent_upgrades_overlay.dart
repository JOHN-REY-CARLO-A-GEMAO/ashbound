import 'package:flutter/material.dart';
import '../game/ashbound_game.dart';

class PermanentUpgradesOverlay extends StatefulWidget {
  final ASHBOUNDGame game;

  const PermanentUpgradesOverlay({super.key, required this.game});

  @override
  State<PermanentUpgradesOverlay> createState() =>
      _PermanentUpgradesOverlayState();
}

class _PermanentUpgradesOverlayState extends State<PermanentUpgradesOverlay> {
  @override
  Widget build(BuildContext context) {
    final prog = widget.game.progression;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.92),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "PERMANENT PROGRESSION",
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Embers: 🔥 ${prog.embers}",
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.amber, height: 24),

              // Upgrade 1: Max Health
              _buildUpgradeRow(
                title: "Starting Health (+20 HP)",
                level: prog.healthLevel,
                cost: prog.getHealthUpgradeCost(),
                canAfford: prog.embers >= prog.getHealthUpgradeCost(),
                onBuy: () {
                  if (prog.buyHealthUpgrade()) {
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 12),

              // Upgrade 2: Base Attack Damage
              _buildUpgradeRow(
                title: "Starting Sword Damage (+4 DMG)",
                level: prog.damageLevel,
                cost: prog.getDamageUpgradeCost(),
                canAfford: prog.embers >= prog.getDamageUpgradeCost(),
                onBuy: () {
                  if (prog.buyDamageUpgrade()) {
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 12),

              // Upgrade 3: Ember Capacity
              _buildUpgradeRow(
                title: "Max Ember Capacity (+25 Capacity)",
                level: prog.emberCapLevel,
                cost: prog.getEmberCapUpgradeCost(),
                canAfford: prog.embers >= prog.getEmberCapUpgradeCost(),
                onBuy: () {
                  if (prog.buyEmberCapUpgrade()) {
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  widget.game.overlays.remove('PermanentUpgrades');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27272A),
                  foregroundColor: Colors.white,
                ),
                child: const Text("CLOSE"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeRow({
    required String title,
    required int level,
    required int cost,
    required bool canAfford,
    required VoidCallback onBuy,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                "Current Level: $level",
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: canAfford ? onBuy : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford
                  ? Colors.amber.shade800
                  : Colors.grey.shade800,
              foregroundColor: Colors.white,
            ),
            child: Text("Upgrade (🔥 $cost)"),
          ),
        ],
      ),
    );
  }
}
