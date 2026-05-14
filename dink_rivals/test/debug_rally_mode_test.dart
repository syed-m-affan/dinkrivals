import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/game/models/player_side.dart';

void main() {
  test('free rally starts with a live feed and no serve wait', () async {
    final game = DinkRivalsGame(freeRallyDebugMode: true);
    await game.onLoad();

    expect(game.freeRallyDebugMode, isTrue);
    expect(game.isWaitingToServe, isFalse);
    expect(game.ball.state.isInPlay, isTrue);
    expect(game.ball.state.lastHitBy, PlayerSide.opponent);
    expect(game.matchState.pointInProgress, isTrue);
    expect(game.matchState.twoBounceRuleSatisfied, isTrue);
  });

  test('free rally physics does not score or reset out balls', () async {
    final game = DinkRivalsGame(freeRallyDebugMode: true);
    await game.onLoad();
    game.ball.state
      ..x = Court.right + 40
      ..y = Court.bottom + 40
      ..z = 1
      ..vx = 0
      ..vy = 0
      ..vz = -80
      ..lastHitBy = PlayerSide.player
      ..isInPlay = true;

    game.update(0.1);

    expect(game.matchState.playerScore, 0);
    expect(game.matchState.opponentScore, 0);
    expect(game.matchState.matchOver, isFalse);
    expect(game.ball.state.x, greaterThan(Court.right));
    expect(game.ball.state.y, greaterThan(Court.bottom));
  });

  test('resetDebugBallPosition only resets the ball feed', () async {
    final game = DinkRivalsGame(freeRallyDebugMode: true);
    await game.onLoad();
    game.player.state.position.setValues(Court.left + 12, Court.bottom - 12);

    game.resetDebugBallPosition();

    expect(game.player.state.position.x, Court.left + 12);
    expect(game.player.state.position.y, Court.bottom - 12);
    expect(game.ball.state.x, Court.width / 2);
    expect(game.ball.state.y, Court.playerStartY - 42);
    expect(game.ball.state.isInPlay, isTrue);
  });

  test('free rally net contact does not score or reset', () async {
    final game = DinkRivalsGame(freeRallyDebugMode: true);
    await game.onLoad();
    game.ball.state
      ..x = Court.width / 2
      ..y = Court.netY + 20
      ..z = Court.netHeight * 0.5
      ..vx = 0
      ..vy = -60
      ..vz = 0
      ..lastHitBy = PlayerSide.player
      ..hasBouncedThisSide = false
      ..isInPlay = true
      ..arcGravityScale = 0;

    game.update(0.5);

    expect(game.matchState.playerScore, 0);
    expect(game.matchState.opponentScore, 0);
    expect(game.matchState.matchOver, isFalse);
    expect(game.ball.state.y, Court.netY);
    expect(game.ball.state.vy, 0);
  });
}
