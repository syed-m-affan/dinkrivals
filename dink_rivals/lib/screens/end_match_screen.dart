import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/ad_provider.dart';
import '../app/audio_provider.dart';
import '../app/game_provider.dart';
import '../app/router.dart';
import '../game/config/character_visuals.dart';
import '../game/config/visual_palette.dart';
import '../game/models/player_side.dart';
import '../services/save_service.dart';
import '../widgets/arcade_button.dart';
import '../widgets/arcade_panel.dart';
import '../widgets/park_backdrop.dart';

class EndMatchScreen extends ConsumerStatefulWidget {
  const EndMatchScreen({super.key});

  @override
  ConsumerState<EndMatchScreen> createState() => _EndMatchScreenState();
}

class _EndMatchScreenState extends ConsumerState<EndMatchScreen> {
  bool _rewardClaimed = false;
  bool _rewardAvailable = true;
  bool _showingInterstitial = false;

  Future<void> _claimReward() async {
    if (_rewardClaimed || !_rewardAvailable) {
      return;
    }
    ref.read(audioServiceProvider).playMenuClick();
    final didShow = await ref
        .read(adServiceProvider)
        .showRewardedAd(placement: 'post_match_double_reward');
    if (!mounted) {
      return;
    }
    if (didShow) {
      await ref.read(saveDataProvider.notifier).addStars(100);
      if (!mounted) {
        return;
      }
      setState(() => _rewardClaimed = true);
    } else {
      setState(() => _rewardAvailable = false);
    }
  }

  Future<void> _returnToMenu() async {
    if (_showingInterstitial) {
      return;
    }
    ref.read(audioServiceProvider).playMenuClick();
    final game = ref.read(dinkRivalsGameProvider);
    final placement = ref.read(adPlacementSystemProvider);
    final adService = ref.read(adServiceProvider);
    final eligible = placement.isInterstitialEligible(isNaturalBreak: true);
    final ready = await adService.isInterstitialReady();
    if (!mounted) {
      return;
    }
    if (eligible && ready) {
      setState(() => _showingInterstitial = true);
      placement.recordInterstitialShown();
      await adService.maybeShowInterstitial(placement: 'return_to_menu');
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          key: const Key('fake-interstitial-dialog'),
          title: const Text('FAKE INTERSTITIAL'),
          content: const Text('Test ad break after match.'),
          actions: [
            TextButton(
              key: const Key('fake-interstitial-close'),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() => _showingInterstitial = false);
    }
    game.resetMatch();
    if (mounted) {
      context.go(AppRoutes.menu);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(dinkRivalsGameProvider);
    final saveData = ref.watch(saveDataProvider);
    ref.watch(adPlacementTickProvider);
    final adPlacement = ref.watch(adPlacementSystemProvider);
    final match = game.matchState;
    final winnerSide = _winnerSideFor(match.playerScore, match.opponentScore);
    final playerWon = winnerSide == PlayerSide.player;
    final opponentWon = winnerSide == PlayerSide.opponent;
    final winnerText = switch (winnerSide) {
      PlayerSide.player => 'YOU WIN',
      PlayerSide.opponent => 'OPPONENT WINS',
      null => 'MATCH COMPLETE',
    };
    final winnerColor = switch (winnerSide) {
      PlayerSide.player => VisualPalette.feedbackDink,
      PlayerSide.opponent => VisualPalette.feedbackFault,
      null => VisualPalette.uiAccent,
    };
    final rewardText =
        _rewardClaimed ? 'REWARD CLAIMED 2X' : 'MATCH REWARD 100';
    final winnerPortrait = switch (winnerSide) {
      PlayerSide.player => CharacterVisuals.gameplayPlayer.portraitAsset,
      PlayerSide.opponent => CharacterVisuals.gameplayOpponent.portraitAsset,
      null => CharacterVisuals.gameplayPlayer.portraitAsset,
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _returnToMenu();
      },
      child: Scaffold(
        body: ParkBackdrop(
          overlayOpacity: 0.82,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ArcadePanel(
                      backgroundColor:
                          VisualPalette.uiSurface.withValues(alpha: 0.88),
                      borderColor:
                          VisualPalette.courtLineWhite.withValues(alpha: 0.52),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            winnerPortrait,
                            key: const Key('end-match-winner-portrait'),
                            width: 64,
                            height: 64,
                            filterQuality: FilterQuality.none,
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Text(
                              winnerText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: winnerColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ArcadePanel(
                      backgroundColor:
                          VisualPalette.uiSurface.withValues(alpha: 0.88),
                      borderColor:
                          VisualPalette.courtLineWhite.withValues(alpha: 0.52),
                      child: Column(
                        children: [
                          _ScoreLine(
                            label: 'YOU',
                            side: PlayerSide.player,
                            score: match.playerScore,
                            highlight: playerWon,
                          ),
                          const SizedBox(height: 8),
                          _ScoreLine(
                            label: 'OPPONENT',
                            side: PlayerSide.opponent,
                            score: match.opponentScore,
                            highlight: opponentWon,
                          ),
                          const Divider(color: VisualPalette.netMeshStroke),
                          _StatRow(
                            label: 'Rally count',
                            value: '${match.rallyCount}',
                          ),
                          _StatRow(
                            label: 'Longest rally',
                            value: '${match.longestRally}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      rewardText,
                      key: const Key('end-match-reward-label'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _rewardClaimed
                            ? VisualPalette.uiAccent
                            : VisualPalette.courtLineWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'STARS ${saveData.stars}',
                      key: const Key('end-match-stars-label'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: VisualPalette.textSoft,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ArcadeButton(
                      key: const Key('end-match-rewarded-ad'),
                      label: _rewardClaimed
                          ? 'REWARD CLAIMED'
                          : _rewardAvailable
                              ? '2X REWARD AD'
                              : 'AD UNAVAILABLE',
                      icon: Icons.play_circle,
                      onPressed: _rewardAvailable && !_rewardClaimed
                          ? _claimReward
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      adPlacement.debugSummary(isNaturalBreak: true),
                      key: const Key('end-match-ad-debug'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: VisualPalette.netRail,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 32),
                    ArcadeButton(
                      key: const Key('end-match-rematch'),
                      label: 'REMATCH',
                      icon: Icons.replay,
                      onPressed: () {
                        ref.read(audioServiceProvider).playMenuClick();
                        game.resetMatch();
                        context.go(AppRoutes.game);
                      },
                    ),
                    const SizedBox(height: 16),
                    ArcadeButton(
                      key: const Key('end-match-menu'),
                      label: 'RETURN TO MENU',
                      icon: Icons.home,
                      onPressed: _returnToMenu,
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

  PlayerSide? _winnerSideFor(int playerScore, int opponentScore) {
    if (playerScore == opponentScore) {
      return null;
    }
    return playerScore > opponentScore
        ? PlayerSide.player
        : PlayerSide.opponent;
  }
}

class _ScoreLine extends StatelessWidget {
  const _ScoreLine({
    required this.label,
    required this.side,
    required this.score,
    required this.highlight,
  });

  final String label;
  final PlayerSide side;
  final int score;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color =
        highlight ? VisualPalette.textPrimary : VisualPalette.textMuted;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: VisualPalette.textSoft)),
          Text(value, style: const TextStyle(color: VisualPalette.textSoft)),
        ],
      ),
    );
  }
}
