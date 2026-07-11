import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/config/tuning_constants.dart';
import 'package:dink_rivals/game/models/player_side.dart';
import 'package:dink_rivals/game/models/player_state.dart';
import 'package:dink_rivals/game/systems/movement_system.dart';

void main() {
  final system = MovementSystem();

  PlayerState player() => PlayerState(
        position: Vector2(Court.playerStartX, Court.playerStartY),
        side: PlayerSide.player,
      );

  test('cardinal input reaches the release-candidate speed', () {
    final state = player();
    system.update(
      player: state,
      inputX: 1,
      inputY: 0,
      hasInput: true,
      dt: 0,
    );

    expect(Tuning.playerMaxSpeed, 225);
    expect(state.velocity.length, closeTo(225, 0.001));
  });

  test('diagonal input is normalized to the same maximum speed', () {
    final state = player();
    system.update(
      player: state,
      inputX: 1,
      inputY: 1,
      hasInput: true,
      dt: 0,
    );

    expect(state.velocity.length, closeTo(225, 0.001));
  });

  test('movement remains clamped to the player half court', () {
    final state = player()..position.setValues(Court.right, Court.bottom);
    system.update(
      player: state,
      inputX: 1,
      inputY: 1,
      hasInput: true,
      dt: 1,
    );

    expect(state.position.x, Court.right);
    expect(state.position.y, Court.bottom);
  });
}
