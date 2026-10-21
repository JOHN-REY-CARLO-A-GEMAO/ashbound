import 'dart:math';

enum UpgradeType {
  swordDamage,
  maxHealth,
  moveSpeed,
  dodgeCooldown,
  emberDash,
  critChance,
  healOnKill,
  attackRange,
  emberBurst,
}

class UpgradeDefinition {
  final UpgradeType type;
  final String name;
  final String description;
  final String iconSymbol;

  const UpgradeDefinition({
    required this.type,
    required this.name,
    required this.description,
    required this.iconSymbol,
  });
}

class UpgradeSystem {
  static const List<UpgradeDefinition> allUpgrades = [
    UpgradeDefinition(
      type: UpgradeType.swordDamage,
      name: "Flame Blade",
      description: "Increase attack damage by +25%",
      iconSymbol: "⚔️",
    ),
    UpgradeDefinition(
      type: UpgradeType.maxHealth,
      name: "Ashen Fortitude",
      description: "Increase max health by +30% & heal 30 HP",
      iconSymbol: "❤️",
    ),
    UpgradeDefinition(
      type: UpgradeType.moveSpeed,
      name: "Cinder Swiftness",
      description: "Increase movement speed by +20%",
      iconSymbol: "👟",
    ),
    UpgradeDefinition(
      type: UpgradeType.dodgeCooldown,
      name: "Phantom Roll",
      description: "Reduce dodge cooldown by 0.25 seconds",
      iconSymbol: "🌀",
    ),
    UpgradeDefinition(
      type: UpgradeType.emberDash,
      name: "Ember Trail",
      description: "Dodge leaves scorching flames dealing damage to enemies",
      iconSymbol: "🔥",
    ),
    UpgradeDefinition(
      type: UpgradeType.critChance,
      name: "Critical Flame",
      description: "Gain +15% critical hit chance & +25% crit damage",
      iconSymbol: "🎯",
    ),
    UpgradeDefinition(
      type: UpgradeType.healOnKill,
      name: "Siphon Embers",
      description: "Restore 5 HP whenever an enemy is slain",
      iconSymbol: "✨",
    ),
    UpgradeDefinition(
      type: UpgradeType.attackRange,
      name: "Reaching Slash",
      description: "Increase melee attack range and strike arc area",
      iconSymbol: "🗡️",
    ),
    UpgradeDefinition(
      type: UpgradeType.emberBurst,
      name: "Volcanic Pulse",
      description: "Ember Burst radius and shockwave knockback increased",
      iconSymbol: "💥",
    ),
  ];

  static List<UpgradeDefinition> getRandomUpgrades(
    int count, {
    Random? random,
  }) {
    final rng = random ?? Random();
    final List<UpgradeDefinition> pool = List.from(allUpgrades);
    pool.shuffle(rng);
    return pool.take(count).toList();
  }
}
