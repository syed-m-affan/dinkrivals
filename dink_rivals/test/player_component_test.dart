import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/components/opponent_component.dart';
import 'package:dink_rivals/game/components/player_component.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';

void main() {
  test('player animation switches between idle run and swing', () {
    final game = DinkRivalsGame();
    final component = PlayerComponent(game);

    expect(component.currentPoseNameForTesting(), 'idle');

    game.matchState.startPoint();
    expect(component.currentPoseNameForTesting(), 'idle');

    component.state.velocity = Vector2(20, 0);
    component.update(0.016);
    expect(component.currentPoseNameForTesting(), 'run');

    component.state.isSwinging = true;
    component.update(0.016);
    expect(component.currentPoseNameForTesting(), 'swing');
  });

  test('opponent animation switches between idle run and swing', () {
    final game = DinkRivalsGame();
    final component = OpponentComponent(game);

    expect(component.currentPoseNameForTesting(), 'idle');

    game.matchState.startPoint();
    expect(component.currentPoseNameForTesting(), 'idle');

    component.state.velocity = Vector2(0, 20);
    component.update(0.016);
    expect(component.currentPoseNameForTesting(), 'run');

    component.state.isSwinging = true;
    component.update(0.016);
    expect(component.currentPoseNameForTesting(), 'swing');
  });

  test('opponent renders slightly larger for far-court readability', () {
    expect(OpponentComponent.visualScaleFor(0.7), closeTo(0.938, 0.0001));
  });

  test('hit confirm keeps the same character model after swing pose expires',
      () {
    final game = DinkRivalsGame();
    final component = PlayerComponent(game);
    game.matchState.startPoint();

    component.state.isSwinging = true;
    component.showHitConfirm();
    component.update(0.016);
    expect(component.currentPoseNameForTesting(), 'swing');

    component.update(0.18);
    expect(component.currentPoseNameForTesting(), 'idle');
  });

  test('point result keeps character model visually consistent', () {
    final game = DinkRivalsGame();
    final player = PlayerComponent(game);
    final opponent = OpponentComponent(game);
    game.matchState.startPoint();

    player.showPointResult(player.state.side);
    opponent.showPointResult(player.state.side);

    expect(player.currentPoseNameForTesting(), 'idle');
    expect(opponent.currentPoseNameForTesting(), 'idle');

    player.update(0.73);
    opponent.update(0.73);
    expect(player.currentPoseNameForTesting(), 'idle');
    expect(opponent.currentPoseNameForTesting(), 'idle');
  });

  test('point result clears queued hit confirm without changing model', () {
    final game = DinkRivalsGame();
    final component = PlayerComponent(game);
    game.matchState.startPoint();

    component.showHitConfirm();
    component.showPointResult(component.state.side);

    expect(component.currentPoseNameForTesting(), 'idle');
  });
}
