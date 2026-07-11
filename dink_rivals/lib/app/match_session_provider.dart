import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/config/tournament_definitions.dart';
import '../game/models/match_session.dart';
import '../game/systems/opponent_ai_system.dart';

final matchSessionProvider =
    NotifierProvider<MatchSessionNotifier, MatchSessionState>(
  MatchSessionNotifier.new,
);

class MatchSessionNotifier extends Notifier<MatchSessionState> {
  @override
  MatchSessionState build() => const MatchSessionState();

  MatchSession startQuickMatch() {
    final session = MatchSession(
      mode: MatchMode.quickMatch,
      opponentCharacterId: TournamentDefinitions.rookie.id,
      opponentProfile: OpponentAISystem.defaultProfile,
    );
    state = MatchSessionState(active: session);
    return session;
  }

  MatchSession startRivalChallenge(TournamentRival rival) {
    final session = MatchSession(
      mode: MatchMode.rivalChallenge,
      opponentCharacterId: rival.id,
      opponentProfile: rival.aiProfile,
    );
    state = MatchSessionState(active: session);
    return session;
  }

  MatchSession startClassicCupMatch(
    TournamentRival rival, {
    required String round,
  }) {
    final session = MatchSession(
      mode: MatchMode.classicCup,
      opponentCharacterId: rival.id,
      opponentProfile: rival.aiProfile,
      tournamentRound: round,
    );
    state = MatchSessionState(active: session);
    return session;
  }

  void complete({
    required int playerScore,
    required int opponentScore,
    String? unlockedCharacterId,
  }) {
    final session = state.active;
    if (session == null) {
      throw StateError('No active match session is ready to complete.');
    }
    state = MatchSessionState(
      active: session,
      completed: CompletedMatchSummary(
        session: session,
        playerScore: playerScore,
        opponentScore: opponentScore,
        unlockedCharacterId: unlockedCharacterId,
      ),
    );
  }

  MatchSession? rematch() {
    final session = state.completed?.session ?? state.active;
    if (session == null || !session.allowsRematch) {
      return null;
    }
    state = MatchSessionState(active: session);
    return session;
  }

  void clear() {
    state = const MatchSessionState();
  }
}
