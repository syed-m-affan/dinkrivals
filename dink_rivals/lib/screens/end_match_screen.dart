import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/game_provider.dart';
import '../app/router.dart';
import '../game/models/player_side.dart';

class EndMatchScreen extends ConsumerWidget {
  const EndMatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(dinkRivalsGameProvider);
    final match = game.matchState;
    final playerWon = match.playerScore > match.opponentScore;
    final winnerText = playerWon ? 'YOU WIN' : 'OPPONENT WINS';
    final winnerColor =
        playerWon ? const Color(0xFF4FD08B) : const Color(0xFFFF6A6A);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        game.resetMatch();
        context.go(AppRoutes.menu);
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                const SizedBox(height: 40),
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
                  onPressed: () {
                    game.resetMatch();
                    context.go(AppRoutes.menu);
                  },
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
