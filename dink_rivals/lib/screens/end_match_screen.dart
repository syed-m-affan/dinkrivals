import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/ad_provider.dart';
import '../app/game_provider.dart';
import '../app/router.dart';
import '../game/models/player_side.dart';

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
    final didShow = await ref
        .read(adServiceProvider)
        .showRewardedAd(placement: 'post_match_double_reward');
    if (!mounted) {
      return;
    }
    if (didShow) {
      setState(() => _rewardClaimed = true);
    } else {
      setState(() => _rewardAvailable = false);
    }
  }

  Future<void> _returnToMenu() async {
    if (_showingInterstitial) {
      return;
    }
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
    ref.watch(adPlacementTickProvider);
    final adPlacement = ref.watch(adPlacementSystemProvider);
    final match = game.matchState;
    final playerWon = match.playerScore > match.opponentScore;
    final winnerText = playerWon ? 'YOU WIN' : 'OPPONENT WINS';
    final winnerColor =
        playerWon ? const Color(0xFF4FD08B) : const Color(0xFFFF6A6A);
    final rewardText =
        _rewardClaimed ? 'REWARD CLAIMED 2X' : 'MATCH REWARD 100';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _returnToMenu();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                Text(
                  winnerText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: winnerColor,
                  ),
                ),
                const SizedBox(height: 32),
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
                  highlight: !playerWon,
                ),
                const SizedBox(height: 32),
                _StatRow(label: 'Rally count', value: '${match.rallyCount}'),
                _StatRow(
                    label: 'Longest rally', value: '${match.longestRally}'),
                const SizedBox(height: 24),
                Text(
                  rewardText,
                  key: const Key('end-match-reward-label'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _rewardClaimed
                        ? const Color(0xFFFFCB47)
                        : const Color(0xFFC0C8DC),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  key: const Key('end-match-rewarded-ad'),
                  onPressed:
                      _rewardAvailable && !_rewardClaimed ? _claimReward : null,
                  child: Text(
                    _rewardClaimed
                        ? 'REWARD CLAIMED'
                        : _rewardAvailable
                            ? 'WATCH AD: 2X REWARD'
                            : 'REWARDED AD UNAVAILABLE',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  adPlacement.debugSummary(isNaturalBreak: true),
                  key: const Key('end-match-ad-debug'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF8A93AB),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  key: const Key('end-match-rematch'),
                  onPressed: () {
                    game.resetMatch();
                    context.go(AppRoutes.game);
                  },
                  child: const Text('REMATCH'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  key: const Key('end-match-menu'),
                  onPressed: _returnToMenu,
                  child: const Text('RETURN TO MENU'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
    final color = highlight ? Colors.white : const Color(0xFF8A93AB);
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
          Text(label, style: const TextStyle(color: Color(0xFFC0C8DC))),
          Text(value, style: const TextStyle(color: Color(0xFFC0C8DC))),
        ],
      ),
    );
  }
}
