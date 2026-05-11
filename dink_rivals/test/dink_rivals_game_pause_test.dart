import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/dink_rivals_game.dart';

void main() {
  test('paused defaults to false', () {
    final game = DinkRivalsGame();
    expect(game.paused, isFalse);
  });

  test('paused flag is settable in both directions', () {
    final game = DinkRivalsGame();
    game.paused = true;
    expect(game.paused, isTrue);
    game.paused = false;
    expect(game.paused, isFalse);
  });

  test('matchOverNotifier defaults to false', () {
    final game = DinkRivalsGame();
    expect(game.matchOverNotifier.value, isFalse);
  });

  test(
      'manually setting matchState.matchOver does not automatically '
      'flip the notifier (notifier flips only via _awardPoint)', () {
    final game = DinkRivalsGame();
    game.matchState.matchOver = true;
    expect(game.matchOverNotifier.value, isFalse);
  });
}
