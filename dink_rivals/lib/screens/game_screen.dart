import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/ad_provider.dart';
import '../app/audio_provider.dart';
import '../app/game_provider.dart';
import '../app/rival_challenge_provider.dart';
import '../app/router.dart';
import '../app/tournament_provider.dart';
import '../game/config/visual_palette.dart';
import '../game/dink_rivals_game.dart';
import '../game/models/opponent_serve_phase.dart';
import '../game/systems/opponent_ai_system.dart';
import '../game/systems/unlock_system.dart';
import '../services/save_service.dart';
import '../widgets/arcade_button.dart';
import '../widgets/arcade_panel.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  static const UnlockSystem _unlockSystem = UnlockSystem();

  bool _showPause = false;
  bool _handlingMatchOver = false;
  late bool _showTutorial;
  late final DinkRivalsGame _game;

  @override
  void initState() {
    super.initState();
    _game = ref.read(dinkRivalsGameProvider);
    _showTutorial = !ref.read(saveDataProvider).tutorialSeen;
    if (_showTutorial) {
      _game.paused = true;
    }
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
    if (_handlingMatchOver) return;
    _handlingMatchOver = true;
    _finishCompletedMatch();
  }

  Future<void> _finishCompletedMatch() async {
    final playerScore = _game.matchState.playerScore;
    final opponentScore = _game.matchState.opponentScore;
    final playerWon = _unlockSystem.playerWonMatch(
      playerScore: playerScore,
      opponentScore: opponentScore,
    );
    ref.read(adPlacementSystemProvider).recordMatchCompleted();
    await ref.read(saveDataProvider.notifier).recordMatchCompleted();
    await _unlockDinkStreakPaddleIfEarned();
    final tournament = ref.read(tournamentProvider);
    if (tournament.isActive) {
      final defeatedId = tournament.currentOpponentId;
      if (_unlockSystem.shouldUnlockDefeatedRival(
        playerWon: playerWon,
        rivalId: defeatedId,
        saveData: ref.read(saveDataProvider),
      )) {
        await ref.read(saveDataProvider.notifier).unlockCharacter(defeatedId!);
      }
      await ref.read(tournamentProvider.notifier).recordCompletedMatch(
            playerScore: playerScore,
            opponentScore: opponentScore,
          );
      if (mounted) {
        context.go(AppRoutes.tournament);
      }
      return;
    }
    final challengeId = ref.read(rivalChallengeProvider);
    if (challengeId != null) {
      if (_unlockSystem.shouldUnlockDefeatedRival(
        playerWon: playerWon,
        rivalId: challengeId,
        saveData: ref.read(saveDataProvider),
      )) {
        await ref.read(saveDataProvider.notifier).unlockCharacter(challengeId);
      }
      ref.read(rivalChallengeProvider.notifier).reset();
      _game.setOpponentAiProfile(OpponentAISystem.defaultProfile);
    }
    if (mounted) {
      context.go(AppRoutes.endMatch);
    }
  }

  Future<void> _unlockDinkStreakPaddleIfEarned() async {
    if (!_unlockSystem.shouldUnlockDinkStreakPaddle(
      playerDinkContactsThisMatch: _game.matchState.playerDinkContactsThisMatch,
      saveData: ref.read(saveDataProvider),
    )) {
      return;
    }
    await ref.read(saveDataProvider.notifier).unlockDinkStreakPaddle();
  }

  void _setPaused(bool value) {
    _game.paused = value;
    if (value) {
      _game.inputSystem.clearMovement();
    }
    setState(() => _showPause = value);
  }

  void _returnToMenu() {
    ref.read(rivalChallengeProvider.notifier).reset();
    _game.setOpponentAiProfile(OpponentAISystem.defaultProfile);
    _game.resetMatch();
    _game.paused = false;
    context.go(AppRoutes.menu);
  }

  Future<void> _dismissTutorial() async {
    ref.read(audioServiceProvider).playMenuClick();
    await ref.read(saveDataProvider.notifier).setTutorialSeen(true);
    if (!mounted) {
      return;
    }
    _game.paused = false;
    setState(() => _showTutorial = false);
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(dinkRivalsGameProvider);
    final saveData = ref.watch(saveDataProvider);
    game.setSelectedCourt(saveData.activeCourtId);
    game.setSelectedPaddleSkin(saveData.activePaddleSkinId);
    // Keep the game canvas full-bleed in immersive mode, but offset tappable
    // Flutter controls away from cutouts/status areas.
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
        body: Stack(
          children: [
            GameWidget<DinkRivalsGame>(game: game),
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
            if (_showTutorial)
              _TutorialOverlay(
                onDismiss: _dismissTutorial,
              ),
          ],
        ),
      ),
    );
  }
}

class _TutorialOverlay extends StatelessWidget {
  const _TutorialOverlay({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: VisualPalette.overlayScrim,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ArcadePanel(
                backgroundColor: VisualPalette.uiSurface.withValues(
                  alpha: 0.94,
                ),
                borderColor: VisualPalette.uiAccent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'QUICK START',
                      key: Key('tutorial-title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: VisualPalette.uiAccent,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _TutorialCue(
                      icon: Icons.gamepad,
                      label: 'MOVE',
                      detail: 'left ring',
                    ),
                    const _TutorialCue(
                      icon: Icons.navigation,
                      label: 'AIM',
                      detail: 'red arrow',
                    ),
                    const _TutorialCue(
                      icon: Icons.sports_tennis,
                      label: 'SWING',
                      detail: 'right ring',
                    ),
                    const _TutorialCue(
                      icon: Icons.touch_app,
                      label: 'DINK',
                      detail: 'body contact',
                    ),
                    const SizedBox(height: 22),
                    ArcadeButton(
                      key: const Key('tutorial-dismiss'),
                      label: 'PLAY',
                      icon: Icons.play_arrow,
                      onPressed: onDismiss,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TutorialCue extends StatelessWidget {
  const _TutorialCue({
    required this.icon,
    required this.label,
    required this.detail,
  });

  final IconData icon;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: VisualPalette.courtLineWhite, size: 26),
          const SizedBox(width: 14),
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(
                color: VisualPalette.courtLineWhite,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              detail,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: VisualPalette.textSoft,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
