import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/tuning_constants.dart';
import 'package:dink_rivals/game/models/match_state.dart';
import 'package:dink_rivals/game/models/player_side.dart';
import 'package:dink_rivals/game/systems/scoring_system.dart';

void main() {
  test('serving player rally win increments player score', () {
    final match = MatchState();
    final scoring = ScoringSystem();

    final changed = scoring.awardPoint(match, PlayerSide.player);

    expect(changed, isTrue);
    expect(match.playerScore, 1);
    expect(match.opponentScore, 0);
    expect(match.servingSide, PlayerSide.player);
  });

  test('receiving opponent rally win causes side out without scoring', () {
    final match = MatchState();
    final scoring = ScoringSystem();

    final changed = scoring.awardPoint(match, PlayerSide.opponent);

    expect(changed, isFalse);
    expect(match.playerScore, 0);
    expect(match.opponentScore, 0);
    expect(match.servingSide, PlayerSide.opponent);
  });

  test('serving opponent rally win increments opponent score', () {
    final match = MatchState(servingSide: PlayerSide.opponent);
    final scoring = ScoringSystem();

    final changed = scoring.awardPoint(match, PlayerSide.opponent);

    expect(changed, isTrue);
    expect(match.playerScore, 0);
    expect(match.opponentScore, 1);
    expect(match.servingSide, PlayerSide.opponent);
  });

  test('match does not end without win-by-two lead', () {
    final match = MatchState(
      playerScore: Tuning.quickMatchWinningScore - 1,
      opponentScore: Tuning.quickMatchWinningScore - 1,
    );
    final scoring = ScoringSystem();

    scoring.awardPoint(match, PlayerSide.player);

    expect(match.playerScore, Tuning.quickMatchWinningScore);
    expect(match.matchOver, isFalse);
  });

  test('match ends at winning score with win-by-two lead', () {
    final match = MatchState(
      playerScore: Tuning.quickMatchWinningScore,
      opponentScore: Tuning.quickMatchWinningScore - 1,
    );
    final scoring = ScoringSystem();

    scoring.awardPoint(match, PlayerSide.player);

    expect(match.playerScore, Tuning.quickMatchWinningScore + 1);
    expect(match.matchOver, isTrue);
  });

  test('score does not change after match over', () {
    final match = MatchState(
      playerScore: Tuning.quickMatchWinningScore + 1,
      opponentScore: Tuning.quickMatchWinningScore - 1,
      matchOver: true,
    );
    final scoring = ScoringSystem();

    final changed = scoring.awardPoint(match, PlayerSide.opponent);

    expect(changed, isFalse);
    expect(match.playerScore, Tuning.quickMatchWinningScore + 1);
    expect(match.opponentScore, Tuning.quickMatchWinningScore - 1);
  });

  test('rally count and longest rally update deterministically', () {
    final match = MatchState(pointInProgress: true);
    final scoring = ScoringSystem();

    scoring.recordRallyCrossing(match);
    scoring.recordRallyCrossing(match);

    expect(match.rallyCount, 2);
    expect(match.longestRally, 2);

    scoring.awardPoint(match, PlayerSide.player);

    expect(match.pointInProgress, isFalse);
    expect(match.longestRally, 2);
  });
}
