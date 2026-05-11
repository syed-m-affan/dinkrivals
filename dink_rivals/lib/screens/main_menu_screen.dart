import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/audio_provider.dart';
import '../app/app_config.dart';
import '../app/game_provider.dart';
import '../app/router.dart';
import '../game/config/visual_palette.dart';
import '../widgets/arcade_button.dart';
import '../widgets/arcade_panel.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/environment/classic/park_background_overhaul.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.none,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x9910151B),
                  Color(0x3310151B),
                  Color(0xDD10151B),
                ],
                stops: [0, 0.42, 1],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                        color: VisualPalette.courtLineWhite,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: VisualPalette.uiBackground,
                            offset: Offset(0, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 42),
                    ArcadePanel(
                      backgroundColor:
                          VisualPalette.uiSurface.withValues(alpha: 0.86),
                      borderColor:
                          VisualPalette.courtLineWhite.withValues(alpha: 0.65),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ArcadeButton(
                              key: const Key('menu-quick-match'),
                              label: 'QUICK MATCH',
                              icon: Icons.sports_tennis,
                              onPressed: () {
                                ref.read(audioServiceProvider).playMenuClick();
                                ref.read(dinkRivalsGameProvider).resetMatch();
                                context.go(AppRoutes.game);
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ArcadeButton(
                              key: const Key('menu-roster'),
                              label: 'ROSTER',
                              icon: Icons.groups,
                              onPressed: () {
                                ref.read(audioServiceProvider).playMenuClick();
                                context.go(AppRoutes.roster);
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ArcadeButton(
                              key: const Key('menu-settings'),
                              label: 'SETTINGS',
                              icon: Icons.settings,
                              onPressed: () {
                                ref.read(audioServiceProvider).playMenuClick();
                                context.go(AppRoutes.settings);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
