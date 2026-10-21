import 'package:shared_preferences/shared_preferences.dart';

class ProgressionRepository {
  static const String _keySchemaVersion = 'schema_version';
  static const String _keyEmbers = 'perm_embers';
  static const String _keyHealthLvl = 'perm_health_lvl';
  static const String _keyDamageLvl = 'perm_damage_lvl';
  static const String _keyEmberCapLvl = 'perm_ember_cap_lvl';
  static const String _keyMusicVolume = 'music_volume';
  static const String _keySfxVolume = 'sfx_volume';
  static const String _keyReducedShake = 'reduced_shake';

  static const int currentSchemaVersion = 1;

  int _embers = 0;
  int _healthLevel = 0;
  int _damageLevel = 0;
  int _emberCapLevel = 0;
  double _musicVolume = 0.8;
  double _sfxVolume = 1.0;
  bool _reducedShake = false;

  int get embers => _embers;
  int get healthLevel => _healthLevel;
  int get damageLevel => _damageLevel;
  int get emberCapLevel => _emberCapLevel;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  bool get reducedShake => _reducedShake;

  set musicVolume(double val) {
    _musicVolume = val.clamp(0.0, 1.0);
  }

  set sfxVolume(double val) {
    _sfxVolume = val.clamp(0.0, 1.0);
  }

  set reducedShake(bool val) {
    _reducedShake = val;
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final schema = prefs.getInt(_keySchemaVersion) ?? 0;

      if (schema == 0) {
        // Default or initial setup
        _embers = prefs.getInt(_keyEmbers) ?? 0;
        _healthLevel = prefs.getInt(_keyHealthLvl) ?? 0;
        _damageLevel = prefs.getInt(_keyDamageLvl) ?? 0;
        _emberCapLevel = prefs.getInt(_keyEmberCapLvl) ?? 0;
      } else {
        _embers = prefs.getInt(_keyEmbers) ?? 0;
        _healthLevel = prefs.getInt(_keyHealthLvl) ?? 0;
        _damageLevel = prefs.getInt(_keyDamageLvl) ?? 0;
        _emberCapLevel = prefs.getInt(_keyEmberCapLvl) ?? 0;
      }

      _musicVolume = (prefs.getDouble(_keyMusicVolume) ?? 0.8).clamp(0.0, 1.0);
      _sfxVolume = (prefs.getDouble(_keySfxVolume) ?? 1.0).clamp(0.0, 1.0);
      _reducedShake = prefs.getBool(_keyReducedShake) ?? false;
    } catch (e) {
      // Fallback safely to default settings if SharedPreferences errors
      _embers = 0;
      _healthLevel = 0;
      _damageLevel = 0;
      _emberCapLevel = 0;
      _musicVolume = 0.8;
      _sfxVolume = 1.0;
      _reducedShake = false;
    }
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keySchemaVersion, currentSchemaVersion);
      await prefs.setInt(_keyEmbers, _embers);
      await prefs.setInt(_keyHealthLvl, _healthLevel);
      await prefs.setInt(_keyDamageLvl, _damageLevel);
      await prefs.setInt(_keyEmberCapLvl, _emberCapLevel);
      await prefs.setDouble(_keyMusicVolume, _musicVolume);
      await prefs.setDouble(_keySfxVolume, _sfxVolume);
      await prefs.setBool(_keyReducedShake, _reducedShake);
    } catch (_) {
      // Non-blocking disk write failure handling
    }
  }

  int getHealthUpgradeCost() => (_healthLevel + 1) * 30;
  int getDamageUpgradeCost() => (_damageLevel + 1) * 35;
  int getEmberCapUpgradeCost() => (_emberCapLevel + 1) * 25;

  bool buyHealthUpgrade() {
    final cost = getHealthUpgradeCost();
    if (_embers >= cost) {
      _embers -= cost;
      _healthLevel++;
      save();
      return true;
    }
    return false;
  }

  bool buyDamageUpgrade() {
    final cost = getDamageUpgradeCost();
    if (_embers >= cost) {
      _embers -= cost;
      _damageLevel++;
      save();
      return true;
    }
    return false;
  }

  bool buyEmberCapUpgrade() {
    final cost = getEmberCapUpgradeCost();
    if (_embers >= cost) {
      _embers -= cost;
      _emberCapLevel++;
      save();
      return true;
    }
    return false;
  }

  void addEmbers(int amount) {
    if (amount > 0) {
      _embers += amount;
      save();
    }
  }
}
