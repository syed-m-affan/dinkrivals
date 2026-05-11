import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';

void main() {
  test('player remains locked in place while waiting to serve', () async {
    final game = DinkRivalsGame();
    await game.onLoad();
    game.resetPoint();
    game.inputSystem.setMovement(1, -1);

    final start = game.player.state.position.clone();
    game.update(0.25);

    expect(game.ball.state.isInPlay, isFalse);
    expect(game.player.state.position.x, start.x);
    expect(game.player.state.position.y, start.y);
    expect(game.player.state.velocity.length, 0);
  });

  test('serve-state ball follows racket while player position stays fixed',
      () async {
    final game = DinkRivalsGame();
    await game.onLoad();
    game.resetPoint();

    game.inputSystem.swingRacket(0.4, 1.5708);
    game.update(0.1);

    final racketTip = game.playerRacketPosition();
    expect(game.player.state.position.x, Court.playerStartX);
    expect(game.player.state.position.y, Court.playerStartY);
    expect(game.ball.state.x, closeTo(racketTip.x, 0.01));
    expect(game.ball.state.y, closeTo(racketTip.y, 0.01));
  });
}
