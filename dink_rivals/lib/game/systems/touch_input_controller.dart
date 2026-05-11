import 'dart:math' as math;

import 'package:flame/components.dart';

import '../config/tuning_constants.dart';
import '../models/gameplay_control_mode.dart';
import '../models/swing_intent.dart';
import 'input_system.dart';

class TouchControlLayout {
  TouchControlLayout(this.size);

  final Vector2 size;

  Vector2 get moveCenter => Vector2(size.x * 0.24, size.y - 118);
  double get moveRadius => 58;
  double get moveVisualRadius => 48;

  Vector2 get swingCenter => Vector2(size.x * 0.78, size.y - 132);
  double get swingRadius => 88;
  double get swingVisualRadius => 66;

  Vector2 get serveCenter => Vector2(size.x * 0.5, size.y - 96);
  double get serveRadius => 44;
  double get serveVisualRadius => 38;

  bool isInMoveControl(Vector2 position) {
    return position.distanceTo(moveCenter) <= moveRadius * 1.35;
  }

  bool isInSwingControl(Vector2 position) {
    return position.x >= size.x / 2 &&
        position.distanceTo(swingCenter) <= swingRadius * 1.56;
  }

  bool isInServeButton(Vector2 position) {
    return position.distanceTo(serveCenter) <= serveRadius;
  }
}

class TouchInputController {
  int? _movementPointerId;
  int? _swingPointerId;
  Vector2? _swingStartPosition;
  Vector2? _swingLastPosition;
  DateTime? _swingStartedAt;

  int? get movementPointerId => _movementPointerId;
  int? get swingPointerId => _swingPointerId;

  bool handlePointerStart({
    required int pointerId,
    required Vector2 position,
    required Vector2 size,
    required bool canMove,
    required InputSystem inputSystem,
    required GameplayControlMode controlMode,
  }) {
    final layout = TouchControlLayout(size);
    if (layout.isInSwingControl(position) && _swingPointerId == null) {
      _swingPointerId = pointerId;
      _swingStartPosition = position.clone();
      _swingLastPosition = position.clone();
      _swingStartedAt = DateTime.now();
      if (controlMode == GameplayControlMode.assistedAimGesture) {
        _setAimFromPosition(
          position: position,
          layout: layout,
          inputSystem: inputSystem,
        );
      }
      return true;
    }
    if (!canMove) {
      return false;
    }
    if (layout.isInMoveControl(position) && _movementPointerId == null) {
      _movementPointerId = pointerId;
      _setJoystickFromPosition(
        position: position,
        layout: layout,
        inputSystem: inputSystem,
      );
      return true;
    }
    return false;
  }

  bool handlePointerUpdate({
    required int pointerId,
    required Vector2 position,
    required Vector2 size,
    required bool canMove,
    required InputSystem inputSystem,
    required GameplayControlMode controlMode,
  }) {
    final layout = TouchControlLayout(size);
    if (pointerId == _movementPointerId) {
      if (canMove) {
        _setJoystickFromPosition(
          position: position,
          layout: layout,
          inputSystem: inputSystem,
        );
      }
      return true;
    }
    if (pointerId == _swingPointerId) {
      if (controlMode == GameplayControlMode.assistedAimGesture) {
        _setAimFromPosition(
          position: position,
          layout: layout,
          inputSystem: inputSystem,
        );
        _swingLastPosition = position.clone();
        return true;
      }
      _swingRacketFromPosition(position, inputSystem);
      return true;
    }
    return false;
  }

  bool handlePointerEnd({
    required int pointerId,
    required Vector2 size,
    required InputSystem inputSystem,
    required GameplayControlMode controlMode,
  }) {
    if (pointerId == _movementPointerId) {
      _movementPointerId = null;
      inputSystem.clearMovement();
      return true;
    }
    if (pointerId == _swingPointerId) {
      if (controlMode == GameplayControlMode.assistedAimGesture) {
        final layout = TouchControlLayout(size);
        final start = _swingStartPosition ?? layout.swingCenter;
        final end = _swingLastPosition ?? start;
        final elapsed = DateTime.now()
            .difference(_swingStartedAt ?? DateTime.now())
            .inMilliseconds;
        _submitAssistedSwing(
          start: start,
          end: end,
          elapsedMilliseconds: elapsed,
          inputSystem: inputSystem,
        );
      }
      _clearSwingPointer();
      return true;
    }
    return false;
  }

  void clearMovement(InputSystem inputSystem) {
    _movementPointerId = null;
    inputSystem.clearMovement();
  }

  void _clearSwingPointer() {
    _swingPointerId = null;
    _swingStartPosition = null;
    _swingLastPosition = null;
    _swingStartedAt = null;
  }

  void _setJoystickFromPosition({
    required Vector2 position,
    required TouchControlLayout layout,
    required InputSystem inputSystem,
  }) {
    final offset = position - layout.moveCenter;
    final clamped = offset.length > layout.moveRadius
        ? (offset.normalized()..scale(layout.moveRadius))
        : offset;
    inputSystem.setMovement(
      clamped.x / layout.moveRadius,
      clamped.y / layout.moveRadius,
    );
  }

  void _setAimFromPosition({
    required Vector2 position,
    required TouchControlLayout layout,
    required InputSystem inputSystem,
  }) {
    final offset = position - layout.swingCenter;
    if (offset.length2 < 64) {
      inputSystem.setAimDirection(Vector2(0, -1));
      return;
    }
    final aim = Vector2(
      (offset.x / layout.swingRadius).clamp(-1.0, 1.0).toDouble(),
      (offset.y / layout.swingRadius).clamp(-1.0, 1.0).toDouble(),
    );
    if (aim.y > -0.12) {
      aim.y = -0.12;
    }
    inputSystem.setAimDirection(aim);
  }

  void _submitAssistedSwing({
    required Vector2 start,
    required Vector2 end,
    required int elapsedMilliseconds,
    required InputSystem inputSystem,
  }) {
    final delta = end - start;
    final distance = delta.length;
    final absX = delta.x.abs();
    final absY = delta.y.abs();
    final intent = _intentForGesture(
      delta: delta,
      distance: distance,
      absX: absX,
      absY: absY,
      elapsedMilliseconds: elapsedMilliseconds,
    );
    final flickPower = (distance / Tuning.assistedDriveGestureDistance)
        .clamp(0.0, 1.0)
        .toDouble();
    final holdPower = (elapsedMilliseconds / Tuning.assistedLobHoldMilliseconds)
        .clamp(0.0, 1.0)
        .toDouble();
    final power = switch (intent) {
      SwingIntent.dink => 0.22,
      SwingIntent.drive => math.max(0.42, flickPower),
      SwingIntent.lob => math.max(0.55, holdPower),
      SwingIntent.smash => math.max(0.72, flickPower),
    };
    inputSystem.submitSwingCommand(
      intent: intent,
      aimDirection: inputSystem.aimDirection,
      power: power,
    );
  }

  SwingIntent _intentForGesture({
    required Vector2 delta,
    required double distance,
    required double absX,
    required double absY,
    required int elapsedMilliseconds,
  }) {
    final isMostlyVertical = absY > absX * 0.8;
    if (delta.y > Tuning.assistedSmashGestureDistance && isMostlyVertical) {
      return SwingIntent.smash;
    }
    if (elapsedMilliseconds >= Tuning.assistedLobHoldMilliseconds) {
      return SwingIntent.lob;
    }
    if (distance >= Tuning.assistedDriveGestureDistance) {
      return SwingIntent.drive;
    }
    return SwingIntent.dink;
  }

  void _swingRacketFromPosition(Vector2 position, InputSystem inputSystem) {
    final previous = _swingLastPosition ?? position;
    final delta = position - previous;
    inputSystem.swingRacket(
      delta.x * Tuning.racketSwingRadiansPerPixel,
      Tuning.maxRacketAngleRadians,
    );
    _swingLastPosition = position.clone();
  }
}
