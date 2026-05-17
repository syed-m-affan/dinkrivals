import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/ad_provider.dart';
import '../app/audio_provider.dart';
import '../app/game_provider.dart';
import '../app/rival_challenge_provider.dart';
import '../app/router.dart';
import '../app/tournament_provider.dart';
import '../game/config/tournament_definitions.dart';
import '../game/config/visual_palette.dart';
import '../game/models/tournament_state.dart';
import '../services/save_service.dart';
import '../widgets/arcade_button.dart';
import '../widgets/arcade_panel.dart';
import '../widgets/park_backdrop.dart';

class TournamentScreen extends ConsumerWidget {
  const TournamentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tournamentProvider);
    final saveData = ref.watch(saveDataProvider);
    return Scaffold(
      body: ParkBackdrop(
        overlayOpacity: 0.78,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
                const SizedBox(height: 22),
                _TrophyPanel(wins: saveData.classicCupWins),
                const SizedBox(height: 18),
                _BracketPanel(state: state),
                if (state.isComplete) ...[
                  const SizedBox(height: 18),
                  _ResultPanel(state: state),
                ],
                const SizedBox(height: 22),
                _TournamentActions(state: state),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return ArcadePanel(
      backgroundColor: VisualPalette.uiSurface.withValues(alpha: 0.88),
      borderColor: VisualPalette.uiAccent,
      child: const Column(
        children: [
          Text(
            TournamentDefinitions.classicCupName,
            key: Key('tournament-title'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: VisualPalette.courtLineWhite,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '4-player single elimination',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: VisualPalette.textSoft,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrophyPanel extends StatelessWidget {
  const _TrophyPanel({required this.wins});

  final int wins;

  @override
  Widget build(BuildContext context) {
    final unlocked = wins > 0;
    return ArcadePanel(
      backgroundColor: VisualPalette.uiSurface.withValues(alpha: 0.84),
      borderColor: unlocked
          ? VisualPalette.feedbackDink
          : VisualPalette.courtLineWhite.withValues(alpha: 0.42),
      child: Row(
        children: [
          Icon(
            unlocked ? Icons.emoji_events : Icons.lock,
            key: const Key('tournament-trophy-icon'),
            color:
                unlocked ? VisualPalette.feedbackDink : VisualPalette.textMuted,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              unlocked
                  ? '${TournamentDefinitions.classicCupTrophyName} unlocked'
                  : '${TournamentDefinitions.classicCupTrophyName} locked',
              key: const Key('tournament-trophy-label'),
              style: const TextStyle(
                color: VisualPalette.courtLineWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'WINS $wins',
            key: const Key('tournament-win-count'),
            style: const TextStyle(
              color: VisualPalette.uiAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.state});

  final TournamentState state;

  @override
  Widget build(BuildContext context) {
    final lastMatch =
        state.completedMatches.isEmpty ? null : state.completedMatches.last;
    final playerWon = state.playerWonCup;
    final title = playerWon
        ? 'CHAMPION'
        : 'ELIMINATED IN ${lastMatch?.roundName.toUpperCase() ?? 'CUP'}';
    final detail = playerWon
        ? '${TournamentDefinitions.classicCupTrophyName} unlocked'
        : 'Lost to ${lastMatch?.opponentName ?? 'the rival'}';
    final score = lastMatch == null
        ? '--'
        : '${lastMatch.playerScore}-${lastMatch.opponentScore}';
    final accent =
        playerWon ? VisualPalette.feedbackDink : VisualPalette.feedbackFault;
    return ArcadePanel(
      backgroundColor: VisualPalette.uiSurface.withValues(alpha: 0.88),
      borderColor: accent,
      child: Row(
        key: const Key('tournament-result-panel'),
        children: [
          Icon(
            playerWon ? Icons.emoji_events : Icons.sports_tennis,
            color: accent,
            size: 38,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  key: const Key('tournament-result-title'),
                  style: TextStyle(
                    color: accent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  key: const Key('tournament-result-detail'),
                  style: const TextStyle(
                    color: VisualPalette.courtLineWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            score,
            key: const Key('tournament-result-score'),
            style: TextStyle(
              color: accent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _BracketPanel extends StatelessWidget {
  const _BracketPanel({required this.state});

  final TournamentState state;

  @override
  Widget build(BuildContext context) {
    final semifinal = state.completedMatches
        .where((match) => match.roundName == 'Semifinal')
        .firstOrNull;
    final finalMatch = state.completedMatches
        .where((match) => match.roundName == 'Final')
        .firstOrNull;
    return ArcadePanel(
      backgroundColor: VisualPalette.scoreboardSurface.withValues(alpha: 0.86),
      borderColor: VisualPalette.scoreboardBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'BRACKET',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: VisualPalette.uiAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),
          _MatchRow(
            round: 'SEMIFINAL',
            left: 'YOU',
            right: TournamentDefinitions.semifinalRival.displayName,
            result: semifinal == null
                ? _statusForPending(state, TournamentStatus.semifinal)
                : _scoreText(semifinal),
            highlight: state.status == TournamentStatus.semifinal,
          ),
          const SizedBox(height: 10),
          _MatchRow(
            round: 'SEMIFINAL',
            left: TournamentDefinitions.otherSemifinalRival.displayName,
            right: TournamentDefinitions.finalRival.displayName,
            result: '${TournamentDefinitions.finalRival.displayName} ADV',
            highlight: false,
          ),
          const Divider(color: VisualPalette.netMeshStroke, height: 28),
          _MatchRow(
            round: 'FINAL',
            left: semifinal?.playerWon == true ? 'YOU' : 'TBD',
            right: TournamentDefinitions.finalRival.displayName,
            result: finalMatch == null
                ? _statusForPending(state, TournamentStatus.finalRound)
                : _scoreText(finalMatch),
            highlight: state.status == TournamentStatus.finalRound,
          ),
        ],
      ),
    );
  }

  String _statusForPending(
    TournamentState state,
    TournamentStatus rowStatus,
  ) {
    if (state.status == rowStatus) {
      return 'NEXT';
    }
    if (state.status == TournamentStatus.idle) {
      return 'READY';
    }
    if (state.status == TournamentStatus.eliminated) {
      return 'OUT';
    }
    if (state.status == TournamentStatus.champion) {
      return 'DONE';
    }
    return 'LOCKED';
  }

  String _scoreText(TournamentMatchRecord match) {
    return '${match.playerScore}-${match.opponentScore}';
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({
    required this.round,
    required this.left,
    required this.right,
    required this.result,
    required this.highlight,
  });

  final String round;
  final String left;
  final String right;
  final String result;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color =
        highlight ? VisualPalette.textPrimary : VisualPalette.textSoft;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlight
            ? VisualPalette.feedbackDink.withValues(alpha: 0.14)
            : VisualPalette.uiSurface.withValues(alpha: 0.30),
        border: Border.all(
          color: highlight
              ? VisualPalette.feedbackDink
              : VisualPalette.netMeshStroke.withValues(alpha: 0.55),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 82,
              child: Text(
                round,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            Expanded(
              child: Text(
                '$left  VS  $right',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              result,
              style: TextStyle(
                color: highlight ? VisualPalette.feedbackDink : color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TournamentActions extends ConsumerWidget {
  const _TournamentActions({required this.state});

  final TournamentState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.read(audioServiceProvider);
    final notifier = ref.read(tournamentProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.status == TournamentStatus.idle)
          ArcadeButton(
            key: const Key('tournament-start'),
            label: 'START CUP',
            icon: Icons.emoji_events,
            onPressed: () {
              audio.playMenuClick();
              notifier.startClassicCup();
            },
          )
        else if (state.isActive)
          _PlayMatchButton(state: state)
        else ...[
          if (state.status == TournamentStatus.eliminated) ...[
            const _RetryMatchAdButton(),
            const SizedBox(height: 14),
          ],
          ArcadeButton(
            key: const Key('tournament-restart'),
            label: state.playerWonCup ? 'RUN IT BACK' : 'TRY AGAIN',
            icon: Icons.replay,
            onPressed: () {
              audio.playMenuClick();
              notifier.startClassicCup();
            },
          ),
        ],
        const SizedBox(height: 14),
        ArcadeButton(
          key: const Key('tournament-menu'),
          label: 'MAIN MENU',
          icon: Icons.home,
          onPressed: () async {
            audio.playMenuClick();
            await _maybeShowExitInterstitial(context, ref);
            if (!context.mounted) {
              return;
            }
            context.go(AppRoutes.menu);
          },
        ),
      ],
    );
  }

  Future<void> _maybeShowExitInterstitial(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final placement = ref.read(adPlacementSystemProvider);
    final adService = ref.read(adServiceProvider);
    final eligible = placement.isInterstitialEligible(isNaturalBreak: true);
    final ready = await adService.isInterstitialReady();
    if (!context.mounted || !eligible || !ready) {
      return;
    }

    placement.recordInterstitialShown();
    final didShowInterstitial =
        await adService.maybeShowInterstitial(placement: 'exit_tournament');
    if (!context.mounted ||
        !didShowInterstitial ||
        adService.usesNativeInterstitialUi) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        key: const Key('fake-interstitial-dialog'),
        title: const Text('FAKE INTERSTITIAL'),
        content: const Text('Test ad break after tournament.'),
        actions: [
          TextButton(
            key: const Key('fake-interstitial-close'),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}

class _RetryMatchAdButton extends ConsumerStatefulWidget {
  const _RetryMatchAdButton();

  @override
  ConsumerState<_RetryMatchAdButton> createState() =>
      _RetryMatchAdButtonState();
}

class _RetryMatchAdButtonState extends ConsumerState<_RetryMatchAdButton> {
  bool _adUnavailable = false;
  bool _showingAd = false;

  Future<void> _retry() async {
    if (_showingAd || _adUnavailable) {
      return;
    }
    ref.read(audioServiceProvider).playMenuClick();
    setState(() => _showingAd = true);
    final didShow = await ref
        .read(adServiceProvider)
        .showRewardedAd(placement: 'tournament_retry');
    if (!mounted) {
      return;
    }
    if (didShow) {
      ref.read(tournamentProvider.notifier).retryEliminatedMatch();
    } else {
      setState(() {
        _showingAd = false;
        _adUnavailable = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ArcadeButton(
      key: const Key('tournament-retry-ad'),
      label: _adUnavailable
          ? 'RETRY AD UNAVAILABLE'
          : _showingAd
              ? 'LOADING RETRY'
              : 'RETRY AD',
      icon: Icons.play_circle,
      onPressed: _adUnavailable || _showingAd ? null : _retry,
    );
  }
}

class _PlayMatchButton extends ConsumerWidget {
  const _PlayMatchButton({required this.state});

  final TournamentState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rival = ref.read(tournamentProvider.notifier).currentRival();
    final round =
        state.status == TournamentStatus.semifinal ? 'SEMIFINAL' : 'FINAL';
    return ArcadeButton(
      key: const Key('tournament-play-match'),
      label: 'PLAY $round',
      icon: Icons.sports_tennis,
      onPressed: rival == null
          ? null
          : () {
              ref.read(audioServiceProvider).playMenuClick();
              ref.read(rivalChallengeProvider.notifier).reset();
              final game = ref.read(dinkRivalsGameProvider);
              game.setOpponentAiProfile(rival.aiProfile);
              game.resetMatch();
              context.go(AppRoutes.game);
            },
    );
  }
}
