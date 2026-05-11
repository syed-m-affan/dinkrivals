import 'dart:math' as math;

import 'package:flame/components.dart';

import '../config/tuning_constants.dart';
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
  int? _shotPointerId;
  Vector2? _shotStartPosition;
  Vector2? _shotLastPosition;

  int? get movementPointerId => _movementPointerId;
  int? get swingPointerId => _swingPointerId;
  int? get shotPointerId => _shotPointerId;

  bool handlePointerStart({
    required int pointerId,
    required Vector2 position,
    required Vector2 size,
    required bool canMove,
    required InputSystem inputSystem,
  }) {
    final layout = TouchControlLayout(size);
    if (layout.isInSwingControl(position) && _swingPointerId == null) {
      _swingPointerId = pointerId;
      _setAimFromPosition(
        position: position,
        layout: layout,
        inputSystem: inputSystem,
      );
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
    if (_shotPointerId == null &&
        !layout.isInMoveControl(position) &&
        !layout.isInServeButton(position)) {
      _shotPointerId = pointerId;
      _shotStartPosition = position.clone();
      _shotLastPosition = position.clone();
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
      _setAimFromPosition(
        position: position,
        layout: layout,
        inputSystem: inputSystem,
      );
      return true;
    }
    if (pointerId == _shotPointerId) {
      _shotLastPosition = position.clone();
      return true;
    }
    return false;
  }

  bool handlePointerEnd({
    required int pointerId,
    required Vector2 size,
    required InputSystem inputSystem,
  }) {
    if (pointerId == _movementPointerId) {
      _movementPointerId = null;
      inputSystem.clearMovement();
      return true;
    }
    if (pointerId == _swingPointerId) {
      _clearSwingPointer();
      return true;
    }
    if (pointerId == _shotPointerId) {
      final start = _shotStartPosition;
      final end = _shotLastPosition ?? start;
      if (start != null && end != null) {
        _submitSwipeShot(
          start: start,
          end: end,
          inputSystem: inputSystem,
        );
      }
      _clearShotPointer();
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
  }

  void _clearShotPointer() {
    _shotPointerId = null;
    _shotStartPosition = null;
    _shotLastPosition = null;
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

  void _submitSwipeShot({
    required Vector2 start,
    required Vector2 end,
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
    );
    if (intent == null) {
      return;
    }
    final flickPower =
        (distance / Tuning.shotSwipeDistance).clamp(0.0, 1.0).toDouble();
    final power = switch (intent) {
      SwingIntent.dink => 0.18,
      SwingIntent.drive => math.max(0.66, flickPower),
      SwingIntent.lob => math.max(0.62, flickPower * 0.82),
      SwingIntent.smash => math.max(0.72, flickPower),
    };
    inputSystem.submitSwingCommand(
      intent: intent,
      aimDirection: _aimForGesture(
        intent: intent,
        delta: delta,
        distance: distance,
        inputSystem: inputSystem,
      ),
      power: power,
    );
  }

  Vector2 _aimForGesture({
    required SwingIntent intent,
    required Vector2 delta,
    required double distance,
    required InputSystem inputSystem,
  }) {
    if (intent != SwingIntent.drive || distance < 0.01) {
      return inputSystem.aimDirection;
    }
    return Vector2(
      (delta.x / distance).clamp(-1.0, 1.0).toDouble(),
      -0.95,
    );
  }

  SwingIntent? _intentForGesture({
    required Vector2 delta,
    required double distance,
    required double absX,
    required double absY,
  }) {
    if (distance < Tuning.shotSwipeDistance) {
      return null;
    }
    final isMostlyVertical = absY > absX * 1.05;
    final isMostlyHorizontal = absX >= absY * 0.85;
    if (delta.y > Tuning.shotSwipeDistance && isMostlyVertical) {
      return SwingIntent.smash;
    }
    if (delta.y < -Tuning.shotSwipeDistance && isMostlyVertical) {
      return SwingIntent.lob;
    }
    if (isMostlyHorizontal) {
      return SwingIntent.drive;
    }
    return null;
  }
}
