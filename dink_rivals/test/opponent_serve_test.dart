import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/game/models/opponent_serve_phase.dart';
import 'package:dink_rivals/game/models/player_side.dart';

void main() {
  test('opponent serve phase defaults to none', () {
    final game = DinkRivalsGame();
    expect(game.opponentServePhase.value, OpponentServePhase.none);
    expect(game.opponentServeCountdown.value, 0);
  });

  test('confirmOpponentServeReady is a no-op when phase is none', () {
    final game = DinkRivalsGame();
    game.confirmOpponentServeReady();
    expect(game.opponentServePhase.value, OpponentServePhase.none);
  });

  test('resetMatch forces servingSide back to the player', () {
    final game = DinkRivalsGame();
    game.matchState.servingSide = PlayerSide.opponent;
    game.resetMatch();
    expect(game.matchState.servingSide, PlayerSide.player);
    expect(game.opponentServePhase.value, OpponentServePhase.none);
  });
}
