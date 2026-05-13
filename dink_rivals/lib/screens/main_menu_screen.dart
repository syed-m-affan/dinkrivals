import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/audio_provider.dart';
import '../app/game_provider.dart';
import '../app/router.dart';
import '../game/config/visual_palette.dart';
import '../widgets/arcade_button.dart';
import '../widgets/arcade_panel.dart';
import '../widgets/park_backdrop.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ParkBackdrop(
            overlayOpacity: 0.44,
            showCourtImage: false,
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const _Logo(),
                    const SizedBox(height: 54),
                    ArcadePanel(
                      backgroundColor:
                          VisualPalette.uiSurface.withValues(alpha: 0.82),
                      borderColor: VisualPalette.environmentSignBorder
                          .withValues(alpha: 0.78),
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
    return DecoratedBox(
      key: const Key('menu-logo-image'),
      decoration: BoxDecoration(
        color: VisualPalette.environmentSignPanel.withValues(alpha: 0.82),
        border: Border.all(color: VisualPalette.uiAccent, width: 3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x77000000),
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Column(
          children: [
            Text(
              'DINK',
              style: TextStyle(
                color: VisualPalette.courtLineWhite,
                fontSize: 38,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                height: 0.94,
              ),
            ),
            Text(
              'RIVALS',
              style: TextStyle(
                color: VisualPalette.uiAccent,
                fontSize: 38,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                height: 0.94,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
