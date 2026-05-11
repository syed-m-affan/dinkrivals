import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/audio_provider.dart';
import '../app/router.dart';
import '../game/config/visual_palette.dart';
import '../game/models/gameplay_control_mode.dart';
import '../services/save_service.dart';
import '../widgets/arcade_panel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(saveDataProvider);
    final notifier = ref.read(saveDataProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(audioServiceProvider).playMenuClick();
            context.go(AppRoutes.menu);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ArcadePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Phase 5 - arcade settings',
                    style: TextStyle(
                      color: VisualPalette.netRail,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const Divider(color: VisualPalette.netMeshStroke),
                SwitchListTile(
                  key: const Key('settings-assisted-controls-toggle'),
                  title: const Text('Assisted Controls'),
                  subtitle: Text(data.gameplayControlMode.settingsSubtitle),
                  value: data.gameplayControlMode ==
                      GameplayControlMode.assistedAimGesture,
                  onChanged: (value) {
                    ref.read(audioServiceProvider).playMenuClick();
                    notifier.setGameplayControlMode(
                      value
                          ? GameplayControlMode.assistedAimGesture
                          : GameplayControlMode.classicRacketStick,
                    );
                  },
                ),
                SwitchListTile(
                  key: const Key('settings-sound-toggle'),
                  title: const Text('Sound'),
                  subtitle: const Text('Toggle sound effects (Phase 5)'),
                  value: data.soundEnabled,
                  onChanged: (value) {
                    ref.read(audioServiceProvider).playMenuClick();
                    notifier.setSoundEnabled(value);
                  },
                ),
                SwitchListTile(
                  key: const Key('settings-haptics-toggle'),
                  title: const Text('Haptics'),
                  subtitle: const Text('Toggle vibration feedback (Phase 5)'),
                  value: data.hapticsEnabled,
                  onChanged: (value) {
                    ref.read(audioServiceProvider).playMenuClick();
                    notifier.setHapticsEnabled(value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
