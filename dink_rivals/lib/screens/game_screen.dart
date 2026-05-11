import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/ad_provider.dart';
import '../app/audio_provider.dart';
import '../app/game_provider.dart';
import '../app/router.dart';
import '../game/config/visual_palette.dart';
import '../game/dink_rivals_game.dart';
import '../game/models/opponent_serve_phase.dart';
import '../services/save_service.dart';
import '../widgets/arcade_button.dart';
import '../widgets/arcade_panel.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _showPause = false;
  late final DinkRivalsGame _game;

  @override
  void initState() {
    super.initState();
    _game = ref.read(dinkRivalsGameProvider);
    _game.matchOverNotifier.addListener(_handleMatchOver);
  }

  @override
  void dispose() {
    _game.matchOverNotifier.removeListener(_handleMatchOver);
    super.dispose();
  }

  void _handleMatchOver() {
    if (!_game.matchOverNotifier.value) return;
    if (!mounted) return;
    ref.read(adPlacementSystemProvider).recordMatchCompleted();
    ref.read(saveDataProvider.notifier).recordMatchCompleted();
    context.go(AppRoutes.endMatch);
  }

  void _setPaused(bool value) {
    _game.paused = value;
    if (value) {
      _game.inputSystem.clearMovement();
    }
    setState(() => _showPause = value);
  }

  void _returnToMenu() {
    _game.resetMatch();
    _game.paused = false;
    context.go(AppRoutes.menu);
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(dinkRivalsGameProvider);
    // viewPadding reports cutout / status-bar / nav-bar insets even when
    // system UI is hidden via `SystemUiMode.immersiveSticky`. SafeArea uses
    // MediaQuery.padding which is zero in immersive mode, so we apply
    // viewPadding manually to keep the game canvas clear of the notch.
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!_showPause) {
          _setPaused(true);
        }
      },
      child: Scaffold(
        backgroundColor: VisualPalette.textInverse,
        body: Padding(
          padding: EdgeInsets.only(
            top: viewPadding.top,
            bottom: viewPadding.bottom,
            left: viewPadding.left,
            right: viewPadding.right,
          ),
          child: Stack(
            children: [
              GameWidget<DinkRivalsGame>(game: game),
              Positioned(
                top: 8,
                right: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: VisualPalette.scoreboardSurface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: VisualPalette.scoreboardBorder),
                  ),
                  child: IconButton(
                    key: const Key('game-pause-button'),
                    iconSize: 30,
                    icon: const Icon(
                      Icons.pause,
                      color: VisualPalette.courtLineWhite,
                    ),
                    onPressed: _showPause
                        ? null
                        : () {
                            ref.read(audioServiceProvider).playMenuClick();
                            _setPaused(true);
                          },
                  ),
                ),
              ),
              if (_showPause)
                _PauseOverlay(
                  onResume: () {
                    ref.read(audioServiceProvider).playMenuClick();
                    _setPaused(false);
                  },
                  onMenu: () {
                    ref.read(audioServiceProvider).playMenuClick();
                    _returnToMenu();
                  },
                ),
              if (!_showPause)
                _OpponentServeOverlay(
                  phaseNotifier: _game.opponentServePhase,
                  countdownNotifier: _game.opponentServeCountdown,
                  onReady: () {
                    ref.read(audioServiceProvider).playMenuClick();
                    _game.confirmOpponentServeReady();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpponentServeOverlay extends StatelessWidget {
  const _OpponentServeOverlay({
    required this.phaseNotifier,
    required this.countdownNotifier,
    required this.onReady,
  });

  final ValueNotifier<OpponentServePhase> phaseNotifier;
  final ValueNotifier<int> countdownNotifier;
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<OpponentServePhase>(
      valueListenable: phaseNotifier,
      builder: (context, phase, _) {
        if (phase == OpponentServePhase.awaitingReady) {
          return Positioned.fill(
            child: ColoredBox(
              color: VisualPalette.overlayScrim,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'OPPONENT TO SERVE',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: VisualPalette.courtLineWhite,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ArcadeButton(
                      key: const Key('opponent-serve-ready'),
                      label: 'READY',
                      icon: Icons.sports_tennis,
                      onPressed: onReady,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (phase == OpponentServePhase.countingDown) {
          return Positioned.fill(
            child: IgnorePointer(
              child: ValueListenableBuilder<int>(
                valueListenable: countdownNotifier,
                builder: (context, count, _) {
                  if (count <= 0) {
                    return const SizedBox.shrink();
                  }
                  return Center(
                    child: Text(
                      '$count',
                      key: const Key('opponent-serve-countdown'),
                      style: const TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: VisualPalette.textPrimary,
                        shadows: [
                          Shadow(
                            color: VisualPalette.scoreboardSurface,
                            offset: Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({required this.onResume, required this.onMenu});

  final VoidCallback onResume;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: VisualPalette.overlayScrim,
        child: Center(
          child: ArcadePanel(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'PAUSED',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: VisualPalette.courtLineWhite,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ArcadeButton(
                    key: const Key('pause-resume'),
                    label: 'RESUME',
                    icon: Icons.play_arrow,
                    onPressed: onResume,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ArcadeButton(
                    key: const Key('pause-menu'),
                    label: 'RETURN TO MENU',
                    icon: Icons.home,
                    onPressed: onMenu,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
