import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/config/tournament_definitions.dart';
import '../game/models/tournament_state.dart';
import '../game/systems/tournament_system.dart';
import '../services/save_service.dart';

final tournamentProvider =
    NotifierProvider<TournamentNotifier, TournamentState>(
  TournamentNotifier.new,
);

class TournamentNotifier extends Notifier<TournamentState> {
  final TournamentSystem _system = const TournamentSystem();

  @override
  TournamentState build() => const TournamentState();

  void startClassicCup() {
    state = _system.startClassicCup();
  }

  void reset() {
    state = const TournamentState();
  }

  TournamentRival? currentRival() {
    final id = state.currentOpponentId;
    return id == null ? null : TournamentDefinitions.byId(id);
  }

  Future<void> recordCompletedMatch({
    required int playerScore,
    required int opponentScore,
  }) async {
    final previous = state;
    final next = _system.recordPlayerMatch(
      state: previous,
      playerScore: playerScore,
      opponentScore: opponentScore,
    );
    state = next;
    if (next.playerWonCup && !previous.playerWonCup) {
      await ref.read(saveDataProvider.notifier).recordClassicCupWin();
    }
  }
}
