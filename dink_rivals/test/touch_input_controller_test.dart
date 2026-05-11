import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/models/gameplay_control_mode.dart';
import 'package:dink_rivals/game/models/swing_intent.dart';
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
      controlMode: GameplayControlMode.assistedAimGesture,
    );

    expect(handled, isTrue);
    expect(input.movementX, greaterThan(0));
    expect(controller.movementPointerId, 1);

    controller.handlePointerEnd(
      pointerId: 1,
      size: size,
      inputSystem: input,
      controlMode: GameplayControlMode.assistedAimGesture,
    );

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
      controlMode: GameplayControlMode.assistedAimGesture,
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
      controlMode: GameplayControlMode.classicRacketStick,
    );
    controller.handlePointerUpdate(
      pointerId: 2,
      position: layout.swingCenter + Vector2(24, 0),
      size: size,
      canMove: false,
      inputSystem: input,
      controlMode: GameplayControlMode.classicRacketStick,
    );

    expect(input.racketAngle, greaterThan(0));
    expect(controller.swingPointerId, 2);

    controller.handlePointerEnd(
      pointerId: 2,
      size: size,
      inputSystem: input,
      controlMode: GameplayControlMode.classicRacketStick,
    );

    expect(controller.swingPointerId, isNull);
  });

  test('assisted swing pad submits a dink command on tap release', () {
    final controller = TouchInputController();
    final input = InputSystem();
    final size = Vector2(360, 720);
    final layout = TouchControlLayout(size);
    final aimPoint = layout.swingCenter + Vector2(0, -40);

    controller.handlePointerStart(
      pointerId: 2,
      position: aimPoint,
      size: size,
      canMove: false,
      inputSystem: input,
      controlMode: GameplayControlMode.assistedAimGesture,
    );
    controller.handlePointerEnd(
      pointerId: 2,
      size: size,
      inputSystem: input,
      controlMode: GameplayControlMode.assistedAimGesture,
    );

    expect(input.activeSwingCommand?.intent, SwingIntent.dink);
    expect(input.activeSwingCommand?.aimDirection.y, lessThan(0));
  });

  test('swing control accepts a larger mobile touch target', () {
    final size = Vector2(360, 720);
    final layout = TouchControlLayout(size);

    expect(layout.swingRadius, 88);
    expect(layout.swingVisualRadius, lessThan(layout.swingRadius));
    expect(
      layout.isInSwingControl(layout.swingCenter + Vector2(116, 0)),
      isTrue,
    );
  });

  test('visual controls are smaller than touch hit regions', () {
    final layout = TouchControlLayout(Vector2(360, 720));

    expect(layout.moveVisualRadius, lessThan(layout.moveRadius));
    expect(layout.swingVisualRadius, lessThan(layout.swingRadius));
    expect(layout.serveVisualRadius, lessThan(layout.serveRadius));
    expect(
        layout.isInServeButton(
          layout.serveCenter + Vector2(layout.serveRadius - 1, 0),
        ),
        isTrue);
  });

  test('visual swing power is read-only and clamps input values', () {
    final input = InputSystem();

    input.racketAngularVelocity = 100;
    expect(input.visualSwingPower, 1);

    input.submitSwingCommand(
      intent: SwingIntent.drive,
      aimDirection: Vector2(0, -1),
      power: 0.48,
    );
    expect(input.visualSwingPower, closeTo(0.48, 0.001));
  });
}
