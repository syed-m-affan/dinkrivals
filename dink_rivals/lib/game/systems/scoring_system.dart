import '../config/tuning_constants.dart';
import '../models/match_state.dart';
import '../models/player_side.dart';

class ScoringSystem {
  bool awardPoint(MatchState match, PlayerSide winner) {
    if (match.matchOver) {
      return false;
    }

    if (winner == PlayerSide.player) {
      match.playerScore++;
    } else {
      match.opponentScore++;
    }

    if (match.rallyCount > match.longestRally) {
      match.longestRally = match.rallyCount;
    }

    match.servingSide = winner;
    match.pointInProgress = false;
    match.matchOver = match.playerScore >= Tuning.quickMatchWinningScore ||
        match.opponentScore >= Tuning.quickMatchWinningScore;
    return true;
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
      ..longestRally = 0;
  }
}
