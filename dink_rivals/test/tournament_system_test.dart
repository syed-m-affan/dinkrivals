import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/tournament_definitions.dart';
import 'package:dink_rivals/game/models/tournament_state.dart';
import 'package:dink_rivals/game/systems/tournament_system.dart';

void main() {
  const system = TournamentSystem();

  test('classic cup starts at player semifinal against rookie', () {
    final state = system.startClassicCup();

    expect(state.status, TournamentStatus.semifinal);
    expect(state.currentOpponentId, TournamentDefinitions.rookie.id);
    expect(state.currentOpponentName, TournamentDefinitions.rookie.displayName);
    expect(state.completedMatches, isEmpty);
  });

  test('semifinal loss eliminates player and records score', () {
    final state = system.recordPlayerMatch(
      state: system.startClassicCup(),
      playerScore: 6,
      opponentScore: 11,
    );

    expect(state.status, TournamentStatus.eliminated);
    expect(state.currentOpponentId, isNull);
    expect(state.completedMatches, hasLength(1));
    expect(state.completedMatches.single.playerWon, isFalse);
  });

  test('semifinal win advances to final opponent', () {
    final state = system.recordPlayerMatch(
      state: system.startClassicCup(),
      playerScore: 11,
      opponentScore: 8,
    );

    expect(state.status, TournamentStatus.finalRound);
    expect(state.currentOpponentId, TournamentDefinitions.showman.id);
    expect(
        state.currentOpponentName, TournamentDefinitions.showman.displayName);
    expect(state.completedMatches.single.roundName, 'Semifinal');
  });

  test('final win marks player as champion', () {
    final finalist = system.recordPlayerMatch(
      state: system.startClassicCup(),
      playerScore: 11,
      opponentScore: 8,
    );

    final champion = system.recordPlayerMatch(
      state: finalist,
      playerScore: 12,
      opponentScore: 10,
    );

    expect(champion.status, TournamentStatus.champion);
    expect(champion.playerWonCup, isTrue);
    expect(champion.currentOpponentId, isNull);
    expect(champion.completedMatches, hasLength(2));
    expect(champion.completedMatches.last.roundName, 'Final');
  });

  test('inactive tournament cannot record a match', () {
    expect(
      () => system.recordPlayerMatch(
        state: const TournamentState(),
        playerScore: 11,
        opponentScore: 4,
      ),
      throwsStateError,
    );
  });
}
