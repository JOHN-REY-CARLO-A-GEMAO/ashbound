import 'dart:math';

class PlayerStats {
  // Base stats
  double baseMaxHealth = 100.0;
  double baseDamage = 15.0;
  double baseMoveSpeed = 160.0;
  double baseAttackRange = 36.0;
  double baseAttackCooldown = 0.4;
  double baseDodgeCooldown = 1.0;
  double baseCritChance = 0.05;
  double baseCritMultiplier = 1.5;
  double baseEmberDashDamage = 0.0;
  double baseHealOnKill = 0.0;
  int baseEmberCapacity = 100;

  // Upgrade Modifiers (Temporary)
  double damageMultiplier = 1.0;
  double healthMultiplier = 1.0;
  double speedMultiplier = 1.0;
  double attackRangeBonus = 0.0;
  double dodgeCooldownReduction = 0.0; // Seconds reduced
  double critChanceBonus = 0.0;
  double critMultiplierBonus = 0.0;
  double emberDashDamage = 0.0;
  double healOnKillAmount = 0.0;

  bool hasEmberBurst = false;
  double emberBurstRadiusBonus = 0.0;
  double emberBurstDamageBonus = 0.0;

  // Permanent Upgrade Levels
  int permHealthLevel = 0;
  int permDamageLevel = 0;
  int permEmberCapacityLevel = 0;

  void applyPermanentUpgrades(int healthLvl, int damageLvl, int emberCapLvl) {
    permHealthLevel = healthLvl;
    permDamageLevel = damageLvl;
    permEmberCapacityLevel = emberCapLvl;
  }

  double get maxHealth => (baseMaxHealth + permHealthLevel * 20.0) * healthMultiplier;
  double get damage => (baseDamage + permDamageLevel * 4.0) * damageMultiplier;
  double get moveSpeed => baseMoveSpeed * speedMultiplier;
  double get attackRange => baseAttackRange + attackRangeBonus;
  double get dodgeCooldown => max(0.3, baseDodgeCooldown - dodgeCooldownReduction);
  double get critChance => min(0.75, baseCritChance + critChanceBonus);
  double get critMultiplier => baseCritMultiplier + critMultiplierBonus;
  int get maxEmbers => baseEmberCapacity + permEmberCapacityLevel * 25;

  void resetTemporaryModifiers() {
    damageMultiplier = 1.0;
    healthMultiplier = 1.0;
    speedMultiplier = 1.0;
    attackRangeBonus = 0.0;
    dodgeCooldownReduction = 0.0;
    critChanceBonus = 0.0;
    critMultiplierBonus = 0.0;
    emberDashDamage = 0.0;
    healOnKillAmount = 0.0;
    hasEmberBurst = false;
    emberBurstRadiusBonus = 0.0;
    emberBurstDamageBonus = 0.0;
  }
}
