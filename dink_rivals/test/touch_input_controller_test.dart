import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/systems/input_system.dart';
import 'package:dink_rivals/game/systems/touch_input_controller.dart';

void main() {
  test('movement pointer sets and clears joystick input', () {
    final controller = TouchInputController();
    final input = InputSystem();
    final size = Vector2(360, 720);
    final layout = TouchControlLayout(size);

    final handled = controller.handlePointerStart(
      pointerId: 1,
      position: layout.moveCenter + Vector2(layout.moveRadius, 0),
      size: size,
      canMove: true,
      inputSystem: input,
    );

    expect(handled, isTrue);
    expect(input.movementX, greaterThan(0));
    expect(controller.movementPointerId, 1);

    controller.handlePointerEnd(pointerId: 1, inputSystem: input);

    expect(input.hasMovementInput, isFalse);
    expect(controller.movementPointerId, isNull);
  });

  test('movement input is ignored while movement is locked', () {
    final controller = TouchInputController();
    final input = InputSystem();
    final size = Vector2(360, 720);
    final layout = TouchControlLayout(size);

    final handled = controller.handlePointerStart(
      pointerId: 1,
      position: layout.moveCenter,
      size: size,
      canMove: false,
      inputSystem: input,
    );

    expect(handled, isFalse);
    expect(input.hasMovementInput, isFalse);
  });

  test('swing pointer changes racket angle and clears independently', () {
    final controller = TouchInputController();
    final input = InputSystem();
    final size = Vector2(360, 720);
    final layout = TouchControlLayout(size);

    controller.handlePointerStart(
      pointerId: 2,
      position: layout.swingCenter,
      size: size,
      canMove: false,
      inputSystem: input,
    );
    controller.handlePointerUpdate(
      pointerId: 2,
      position: layout.swingCenter + Vector2(24, 0),
      size: size,
      canMove: false,
      inputSystem: input,
    );

    expect(input.racketAngle, greaterThan(0));
    expect(controller.swingPointerId, 2);

    controller.handlePointerEnd(pointerId: 2, inputSystem: input);

    expect(controller.swingPointerId, isNull);
  });
}
