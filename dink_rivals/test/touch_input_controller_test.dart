import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/components/touch_controls_component.dart';
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
    );

    expect(handled, isTrue);
    expect(input.movementX, greaterThan(0));
    expect(controller.movementPointerId, 1);

    controller.handlePointerEnd(
      pointerId: 1,
      size: size,
      inputSystem: input,
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
    );

    expect(handled, isFalse);
    expect(input.hasMovementInput, isFalse);
  });

  test('right stick aims racket and clears independently', () {
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

    controller.handlePointerEnd(
      pointerId: 2,
      size: size,
      inputSystem: input,
    );

    expect(controller.swingPointerId, isNull);
  });

  test('screen swipe submits shot command without using aim stick', () {
    final controller = TouchInputController();
    final input = InputSystem();
    final size = Vector2(360, 720);
    final start = Vector2(size.x * 0.5, size.y * 0.45);

    controller.handlePointerStart(
      pointerId: 2,
      position: start,
      size: size,
      canMove: true,
      inputSystem: input,
    );
    controller.handlePointerUpdate(
      pointerId: 2,
      position: start + Vector2(70, 4),
      size: size,
      canMove: true,
      inputSystem: input,
    );
    controller.handlePointerEnd(
      pointerId: 2,
      size: size,
      inputSystem: input,
    );

    expect(input.activeSwingCommand?.intent, SwingIntent.drive);
    expect(input.activeSwingCommand?.aimDirection.x, greaterThan(0));
    expect(input.activeSwingCommand?.swipeDirection.x, greaterThan(0));
    expect(input.activeSwingCommand?.aimDirection.y, lessThan(0));
  });

  test('up and down swipes map to lob and smash', () {
    final controller = TouchInputController();
    final input = InputSystem();
    final size = Vector2(360, 720);
    final start = Vector2(size.x * 0.5, size.y * 0.45);

    controller.handlePointerStart(
      pointerId: 3,
      position: start,
      size: size,
      canMove: true,
      inputSystem: input,
    );
    controller.handlePointerUpdate(
      pointerId: 3,
      position: start + Vector2(0, -54),
      size: size,
      canMove: true,
      inputSystem: input,
    );
    controller.handlePointerEnd(pointerId: 3, size: size, inputSystem: input);
    expect(input.activeSwingCommand?.intent, SwingIntent.lob);

    input.consumeSwingCommand();
    controller.handlePointerStart(
      pointerId: 4,
      position: start,
      size: size,
      canMove: true,
      inputSystem: input,
    );
    controller.handlePointerUpdate(
      pointerId: 4,
      position: start + Vector2(0, 54),
      size: size,
      canMove: true,
      inputSystem: input,
    );
    controller.handlePointerEnd(pointerId: 4, size: size, inputSystem: input);
    expect(input.activeSwingCommand?.intent, SwingIntent.smash);
  });

  test('swing control accepts a larger mobile touch target', () {
    final size = Vector2(360, 720);
    final layout = TouchControlLayout(size);

    expect(layout.swingRadius, 82);
    expect(layout.swingVisualRadius, lessThan(layout.swingRadius));
    expect(
      layout.isInSwingControl(layout.swingCenter + Vector2(112, 0)),
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

  test('clearAll clears every active pointer and transient input', () {
    final controller = TouchInputController();
    final input = InputSystem();
    final size = Vector2(360, 720);
    final layout = TouchControlLayout(size);
    final shotStart = Vector2(size.x * 0.5, size.y * 0.45);

    controller.handlePointerStart(
      pointerId: 1,
      position: layout.moveCenter + Vector2(layout.moveRadius, 0),
      size: size,
      canMove: true,
      inputSystem: input,
    );
    controller.handlePointerStart(
      pointerId: 2,
      position: layout.swingCenter + Vector2(24, 0),
      size: size,
      canMove: true,
      inputSystem: input,
    );
    controller.handlePointerStart(
      pointerId: 3,
      position: shotStart,
      size: size,
      canMove: true,
      inputSystem: input,
    );

    expect(controller.movementPointerId, 1);
    expect(controller.swingPointerId, 2);
    expect(controller.shotPointerId, 3);
    expect(input.hasMovementInput, isTrue);

    controller.clearAll(input);

    expect(controller.movementPointerId, isNull);
    expect(controller.swingPointerId, isNull);
    expect(controller.shotPointerId, isNull);
    expect(input.hasMovementInput, isFalse);
    expect(input.racketAngle, 0);
    expect(input.aimDirection.x, 0);
    expect(input.aimDirection.y, -1);
  });

  test('shot indicator chips stay inside narrow portrait canvas', () {
    final rects = TouchControlsComponent.shotIndicatorRectsForTesting(
      size: Vector2(448, 997),
    );

    for (final rect in rects) {
      expect(rect.left, greaterThanOrEqualTo(8));
      expect(rect.right, lessThanOrEqualTo(440));
    }
  });

  test('expired swing command creates miss recovery window', () {
    final input = InputSystem();

    input.submitSwingCommand(
      intent: SwingIntent.drive,
      aimDirection: Vector2(0, -1),
      swipeDirection: Vector2(1, 0),
      power: 0.48,
    );
    input.updateRacket(0.30);

    expect(input.activeSwingCommand, isNull);
    expect(input.isRecoveringFromSwingMiss, isTrue);
    expect(input.consumeExpiredSwingCommand()?.intent, SwingIntent.drive);
    expect(input.consumeExpiredSwingCommand(), isNull);

    input.updateRacket(0.25);
    expect(input.isRecoveringFromSwingMiss, isFalse);
  });
}
