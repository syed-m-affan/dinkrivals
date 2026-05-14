import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/audio_provider.dart';
import '../app/haptics_provider.dart';
import '../app/router.dart';
import '../game/config/visual_palette.dart';
import '../game/dink_rivals_game.dart';
import '../services/save_service.dart';
import '../widgets/arcade_button.dart';

class DebugRallyScreen extends ConsumerStatefulWidget {
  const DebugRallyScreen({super.key});

  @override
  ConsumerState<DebugRallyScreen> createState() => _DebugRallyScreenState();
}

class _DebugRallyScreenState extends ConsumerState<DebugRallyScreen> {
  late final DinkRivalsGame _game;

  @override
  void initState() {
    super.initState();
    final saveData = ref.read(saveDataProvider);
    _game = DinkRivalsGame(
      audioService: ref.read(audioServiceProvider),
      hapticsService: ref.read(hapticsServiceProvider),
      controlMode: saveData.gameplayControlMode,
      freeRallyDebugMode: true,
    );
  }

  void _returnToMenu() {
    _game.paused = false;
    context.go(AppRoutes.menu);
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _returnToMenu();
      },
      child: Scaffold(
        backgroundColor: VisualPalette.textInverse,
        body: Stack(
          children: [
            GameWidget<DinkRivalsGame>(game: _game),
            Positioned(
              top: viewPadding.top + 8,
              left: viewPadding.left + 8,
              child: ArcadeButton(
                key: const Key('debug-rally-reset-ball'),
                label: 'RESET BALL',
                icon: Icons.restart_alt,
                onPressed: () {
                  ref.read(audioServiceProvider).playMenuClick();
                  _game.resetDebugBallPosition();
                },
              ),
            ),
            Positioned(
              top: viewPadding.top + 8,
              right: viewPadding.right + 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: VisualPalette.scoreboardSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: VisualPalette.scoreboardBorder),
                ),
                child: IconButton(
                  key: const Key('debug-rally-menu'),
                  iconSize: 30,
                  icon: const Icon(
                    Icons.home,
                    color: VisualPalette.courtLineWhite,
                  ),
                  onPressed: () {
                    ref.read(audioServiceProvider).playMenuClick();
                    _returnToMenu();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
