import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/ashbound_game.dart';
import 'overlays/hud_overlay.dart';
import 'overlays/upgrade_selection_overlay.dart';
import 'overlays/main_menu_overlay.dart';
import 'overlays/permanent_upgrades_overlay.dart';
import 'overlays/settings_overlay.dart';
import 'overlays/pause_overlay.dart';
import 'overlays/game_over_overlay.dart';
import 'overlays/victory_overlay.dart';
import 'services/progression_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force Landscape Orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Hide status bar for immersive full screen
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final progression = ProgressionRepository();
  await progression.load();

  final game = ASHBOUNDGame(progression: progression);

  runApp(
    MaterialApp(
      title: 'ASHBOUND',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF09090B),
      ),
      home: Scaffold(
        body: GameWidget<ASHBOUNDGame>(
          game: game,
          initialActiveOverlays: const ['MainMenu'],
          overlayBuilderMap: {
            'MainMenu': (context, game) => MainMenuOverlay(game: game),
            'HUD': (context, game) => HUDOverlay(game: game),
            'UpgradeSelection': (context, game) =>
                UpgradeSelectionOverlay(game: game),
            'PermanentUpgrades': (context, game) =>
                PermanentUpgradesOverlay(game: game),
            'Settings': (context, game) => SettingsOverlay(game: game),
            'Pause': (context, game) => PauseOverlay(game: game),
            'GameOver': (context, game) => GameOverOverlay(game: game),
            'Victory': (context, game) => VictoryOverlay(game: game),
          },
        ),
      ),
    ),
  );
}
