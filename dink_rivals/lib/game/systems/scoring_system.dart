import '../config/tuning_constants.dart';
import '../models/match_state.dart';
import '../models/player_side.dart';

class ScoringSystem {
  bool awardPoint(MatchState match, PlayerSide rallyWinner) {
    if (match.matchOver) {
      return false;
    }

    if (match.rallyCount > match.longestRally) {
      match.longestRally = match.rallyCount;
    }

    final serverWonRally = rallyWinner == match.servingSide;
    if (serverWonRally) {
      if (rallyWinner == PlayerSide.player) {
        match.playerScore++;
      } else {
        match.opponentScore++;
      }
    } else {
      match.servingSide = rallyWinner;
    }

    match.pointInProgress = false;
    match.clearPointBounceState();
    match.matchOver = _hasWon(match.playerScore, match.opponentScore) ||
        _hasWon(match.opponentScore, match.playerScore);
    return serverWonRally;
  }

  void recordRallyCrossing(MatchState match) {
    if (!match.pointInProgress || match.matchOver) {
      return;
    }
    match.rallyCount++;
    if (match.rallyCount > match.longestRally) {
      match.longestRally = match.rallyCount;
    }
  }

  void resetMatch(MatchState match) {
    match
      ..playerScore = 0
      ..opponentScore = 0
      ..servingSide = PlayerSide.player
      ..pointInProgress = false
      ..matchOver = false
      ..rallyCount = 0
      ..playerDinkContactsThisMatch = 0
      ..playerSmashContactsThisMatch = 0
      ..longestRally = 0
      ..clearPointBounceState();
  }

  bool _hasWon(int score, int opponentScore) {
    return score >= Tuning.quickMatchWinningScore &&
        score - opponentScore >= Tuning.quickMatchWinBy;
  }
}
