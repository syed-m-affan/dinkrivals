import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/audio_provider.dart';
import '../app/app_config.dart';
import '../app/game_provider.dart';
import '../app/router.dart';
import '../game/config/visual_palette.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _Logo(),
                const SizedBox(height: 12),
                const Text(
                  AppConfig.phaseLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: VisualPalette.textMuted,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  key: const Key('menu-quick-match'),
                  onPressed: () {
                    ref.read(audioServiceProvider).playMenuClick();
                    ref.read(dinkRivalsGameProvider).resetMatch();
                    context.go(AppRoutes.game);
                  },
                  child: const Text('QUICK MATCH'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  key: const Key('menu-roster'),
                  onPressed: () {
                    ref.read(audioServiceProvider).playMenuClick();
                    context.go(AppRoutes.roster);
                  },
                  child: const Text('ROSTER'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  key: const Key('menu-settings'),
                  onPressed: () {
                    ref.read(audioServiceProvider).playMenuClick();
                    context.go(AppRoutes.settings);
                  },
                  child: const Text('SETTINGS'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/ui/logo.png',
          key: const Key('menu-logo-image'),
          width: 256,
          filterQuality: FilterQuality.none,
          errorBuilder: (_, __, ___) => const Text(
            'DINK RIVALS',
            style: TextStyle(
              color: VisualPalette.courtLineWhite,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}
