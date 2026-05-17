import '../config/tournament_definitions.dart';
import '../models/tournament_state.dart';

class TournamentSystem {
  const TournamentSystem();

  TournamentState startClassicCup() {
    return TournamentState(
      status: TournamentStatus.semifinal,
      currentOpponentId: TournamentDefinitions.semifinalRival.id,
      currentOpponentName: TournamentDefinitions.semifinalRival.displayName,
    );
  }

  TournamentState recordPlayerMatch({
    required TournamentState state,
    required int playerScore,
    required int opponentScore,
  }) {
    if (!state.isActive) {
      throw StateError('No active tournament match is ready to record.');
    }
    final opponentId = state.currentOpponentId;
    final opponentName = state.currentOpponentName;
    if (opponentId == null || opponentName == null) {
      throw StateError('Active tournament match has no current opponent.');
    }

    final record = TournamentMatchRecord(
      roundName: state.currentRoundName,
      opponentId: opponentId,
      opponentName: opponentName,
      playerScore: playerScore,
      opponentScore: opponentScore,
    );
    final completed = [...state.completedMatches, record];
    if (!record.playerWon) {
      return state.copyWith(
        status: TournamentStatus.eliminated,
        currentOpponentId: null,
        currentOpponentName: null,
        completedMatches: completed,
      );
    }

    if (state.status == TournamentStatus.semifinal) {
      return state.copyWith(
        status: TournamentStatus.finalRound,
        currentOpponentId: TournamentDefinitions.finalRival.id,
        currentOpponentName: TournamentDefinitions.finalRival.displayName,
        completedMatches: completed,
      );
    }

    return state.copyWith(
      status: TournamentStatus.champion,
      currentOpponentId: null,
      currentOpponentName: null,
      completedMatches: completed,
    );
  }
}
