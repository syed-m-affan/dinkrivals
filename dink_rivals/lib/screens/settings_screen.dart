import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router.dart';
import '../services/save_service.dart';

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
          onPressed: () => context.go(AppRoutes.menu),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Phase 2 — gray-box settings',
                  style: TextStyle(
                    color: Color(0xFF8A93AB),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Divider(color: Color(0xFF2A2F3D)),
              SwitchListTile(
                key: const Key('settings-sound-toggle'),
                title: const Text('Sound'),
                subtitle: const Text('Toggle sound effects (Phase 5)'),
                value: data.soundEnabled,
                onChanged: (value) => notifier.setSoundEnabled(value),
              ),
              SwitchListTile(
                key: const Key('settings-haptics-toggle'),
                title: const Text('Haptics'),
                subtitle: const Text('Toggle vibration feedback (Phase 5)'),
                value: data.hapticsEnabled,
                onChanged: (value) => notifier.setHapticsEnabled(value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
