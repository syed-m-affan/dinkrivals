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

    component.state.velocity = Vector2(0, 20);
    component.update(0.016);
    expect(component.currentPoseNameForTesting(), 'run');

    component.state.isSwinging = true;
    component.update(0.016);
    expect(component.currentPoseNameForTesting(), 'swing');
  });
}
