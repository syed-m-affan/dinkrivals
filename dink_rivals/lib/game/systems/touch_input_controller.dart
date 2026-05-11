import 'package:flame/components.dart';

import '../config/tuning_constants.dart';
import 'input_system.dart';

class TouchControlLayout {
  TouchControlLayout(this.size);

  final Vector2 size;

  Vector2 get moveCenter => Vector2(size.x * 0.24, size.y - 118);
  double get moveRadius => 58;

  Vector2 get swingCenter => Vector2(size.x * 0.78, size.y - 132);
  double get swingRadius => 58;

  Vector2 get serveCenter => Vector2(size.x * 0.5, size.y - 96);
  double get serveRadius => 44;

  bool isInMoveControl(Vector2 position) {
    return position.distanceTo(moveCenter) <= moveRadius * 1.35;
  }

  bool isInSwingControl(Vector2 position) {
    return position.x >= size.x / 2 &&
        position.distanceTo(swingCenter) <= swingRadius * 1.45;
  }

  bool isInServeButton(Vector2 position) {
    return position.distanceTo(serveCenter) <= serveRadius;
  }
}

class TouchInputController {
  int? _movementPointerId;
  int? _swingPointerId;
  Vector2? _swingLastPosition;

  int? get movementPointerId => _movementPointerId;
  int? get swingPointerId => _swingPointerId;

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
      _swingLastPosition = position.clone();
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
      _swingRacketFromPosition(position, inputSystem);
      return true;
    }
    return false;
  }

  bool handlePointerEnd({
    required int pointerId,
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
    return false;
  }

  void clearMovement(InputSystem inputSystem) {
    _movementPointerId = null;
    inputSystem.clearMovement();
  }

  void _clearSwingPointer() {
    _swingPointerId = null;
    _swingLastPosition = null;
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
