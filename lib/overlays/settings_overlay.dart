import 'package:flutter/material.dart';
import '../game/ashbound_game.dart';

class SettingsOverlay extends StatefulWidget {
  final ASHBOUNDGame game;

  const SettingsOverlay({super.key, required this.game});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  @override
  Widget build(BuildContext context) {
    final prog = widget.game.progression;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.90),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "SETTINGS",
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.amber, height: 24),

              // Music Volume
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Music Volume",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    width: 200,
                    child: Slider(
                      value: prog.musicVolume,
                      activeColor: Colors.amber,
                      onChanged: (val) {
                        setState(() {
                          prog.musicVolume = val;
                        });
                        prog.save();
                      },
                    ),
                  ),
                ],
              ),

              // SFX Volume
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Sound Effects Volume",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    width: 200,
                    child: Slider(
                      value: prog.sfxVolume,
                      activeColor: Colors.amber,
                      onChanged: (val) {
                        setState(() {
                          prog.sfxVolume = val;
                        });
                        prog.save();
                      },
                    ),
                  ),
                ],
              ),

              // Reduced Screen-shake
              SwitchListTile(
                title: const Text(
                  "Reduced Screen Shake",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                value: prog.reducedShake,
                activeColor: Colors.amber,
                onChanged: (val) {
                  setState(() {
                    prog.reducedShake = val;
                  });
                  prog.save();
                },
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  widget.game.overlays.remove('Settings');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27272A),
                  foregroundColor: Colors.white,
                ),
                child: const Text("BACK"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
