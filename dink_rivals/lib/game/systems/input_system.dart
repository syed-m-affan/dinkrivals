import 'dart:math' as math;

import 'package:flame/components.dart';

import '../config/tuning_constants.dart';
import '../models/swing_intent.dart';

class SwingCommand {
  SwingCommand({
    required this.intent,
    required Vector2 aimDirection,
    required this.power,
    required this.remainingSeconds,
  }) : aimDirection = aimDirection.normalized();

  final SwingIntent intent;
  final Vector2 aimDirection;
  final double power;
  double remainingSeconds;
}

class InputSystem {
  double movementX = 0;
  double movementY = 0;
  double racketAngle = 0;
  double racketAngularVelocity = 0;
  Vector2 aimDirection = Vector2(0, -1);

  double _previousRacketAngle = 0;
  SwingCommand? _activeSwingCommand;

  SwingCommand? get activeSwingCommand => _activeSwingCommand;

  bool get hasMovementInput => movementX != 0 || movementY != 0;

  double get visualSwingPower {
    final commandPower = _activeSwingCommand?.power;
    if (commandPower != null) {
      return commandPower.clamp(0.0, 1.0).toDouble();
    }
    return (racketAngularVelocity.abs() / 7.5).clamp(0.0, 1.0).toDouble();
  }

  void setMovement(double x, double y) {
    movementX = x;
    movementY = y;
  }

  void clearMovement() {
    movementX = 0;
    movementY = 0;
  }

  void updateRacket(double dt) {
    if (dt <= 0) {
      racketAngularVelocity = 0;
      return;
    }
    racketAngularVelocity = (racketAngle - _previousRacketAngle) / dt;
    _previousRacketAngle = racketAngle;

    final command = _activeSwingCommand;
    if (command == null) {
      return;
    }
    command.remainingSeconds -= dt;
    if (command.remainingSeconds <= 0) {
      _activeSwingCommand = null;
    }
  }

  void swingRacket(double deltaRadians, double maxAngle) {
    racketAngle =
        (racketAngle + deltaRadians).clamp(-maxAngle, maxAngle).toDouble();
    _setAimFromRacketAngle();
  }

  void setAimDirection(Vector2 direction) {
    if (direction.length2 < 0.01) {
      aimDirection.setValues(0, -1);
    } else {
      aimDirection.setFrom(direction.normalized());
    }
    racketAngle = math.atan2(aimDirection.x, -aimDirection.y);
    racketAngle = racketAngle
        .clamp(-Tuning.maxRacketAngleRadians, Tuning.maxRacketAngleRadians)
        .toDouble();
  }

  void submitSwingCommand({
    required SwingIntent intent,
    required Vector2 aimDirection,
    required double power,
  }) {
    setAimDirection(aimDirection);
    _activeSwingCommand = SwingCommand(
      intent: intent,
      aimDirection: this.aimDirection.clone(),
      power: power.clamp(0.0, 1.0).toDouble(),
      remainingSeconds: Tuning.shotSwipeWindowSeconds,
    );
  }

  void consumeSwingCommand() {
    _activeSwingCommand = null;
  }

  void resetRacket() {
    racketAngle = 0;
    racketAngularVelocity = 0;
    aimDirection.setValues(0, -1);
    _previousRacketAngle = 0;
    _activeSwingCommand = null;
  }

  void _setAimFromRacketAngle() {
    aimDirection.setValues(math.sin(racketAngle), -math.cos(racketAngle));
  }
}
