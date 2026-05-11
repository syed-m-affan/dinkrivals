import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/audio_provider.dart';
import '../app/router.dart';
import '../game/config/visual_palette.dart';
import '../services/save_service.dart';
import '../widgets/arcade_panel.dart';
import '../widgets/park_backdrop.dart';

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
      body: ParkBackdrop(
        overlayOpacity: 0.80,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ArcadePanel(
              backgroundColor: VisualPalette.uiSurface.withValues(alpha: 0.88),
              borderColor: VisualPalette.courtLineWhite.withValues(alpha: 0.52),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'MATCH OPTIONS',
                      style: TextStyle(
                        color: VisualPalette.netRail,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Divider(color: VisualPalette.netMeshStroke),
                  SwitchListTile(
                    key: const Key('settings-sound-toggle'),
                    title: const Text('Sound'),
                    subtitle: const Text('Toggle match sound effects'),
                    value: data.soundEnabled,
                    onChanged: (value) {
                      ref.read(audioServiceProvider).playMenuClick();
                      notifier.setSoundEnabled(value);
                    },
                  ),
                  SwitchListTile(
                    key: const Key('settings-haptics-toggle'),
                    title: const Text('Haptics'),
                    subtitle: const Text('Toggle vibration feedback'),
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
      ),
    );
  }
}
