import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/game_provider.dart';
import '../app/router.dart';
import '../game/dink_rivals_game.dart';
import '../services/save_service.dart';

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
        backgroundColor: Colors.black,
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
                child: IconButton(
                  key: const Key('game-pause-button'),
                  iconSize: 36,
                  icon: const Icon(Icons.pause_circle_filled,
                      color: Colors.white70),
                  onPressed: _showPause ? null : () => _setPaused(true),
                ),
              ),
              if (_showPause)
                _PauseOverlay(
                  onResume: () => _setPaused(false),
                  onMenu: _returnToMenu,
                ),
            ],
          ),
        ),
      ),
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
        color: const Color(0xCC000000),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                key: const Key('pause-resume'),
                onPressed: onResume,
                child: const Text('RESUME'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                key: const Key('pause-menu'),
                onPressed: onMenu,
                child: const Text('RETURN TO MENU'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
