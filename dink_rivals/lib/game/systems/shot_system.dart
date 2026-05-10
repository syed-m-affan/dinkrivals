import 'dart:math' as math;

import 'package:flame/components.dart';

import '../config/court_constants.dart';
import '../config/tuning_constants.dart';
import '../models/ball_state.dart';
import '../models/player_side.dart';
import '../models/player_state.dart';
import '../models/shot_type.dart';

class ShotSystem {
  ShotSystem({math.Random? random}) : _random = random ?? math.Random();

  final math.Random _random;
  ShotType? lastShotType;

  bool attemptShot({
    required BallState ball,
    required PlayerState hitter,
    required PlayerState opponent,
    required ShotType shotType,
  }) {
    if (!_isHittable(ball, hitter)) {
      hitter.isSwinging = true;
      return false;
    }

    final target = _targetFor(shotType, hitter.side, hitter, opponent);
    _applyShot(ball, target, hitter.side, shotType);
    hitter.isSwinging = true;
    lastShotType = shotType;
    return true;
  }

  bool _isHittable(BallState ball, PlayerState hitter) {
    final distance = hitter.position.distanceTo(Vector2(ball.x, ball.y));
    final onHitterSide = hitter.side == PlayerSide.player
        ? ball.y >= Court.netY
        : ball.y <= Court.netY;
    return ball.z >= 5 &&
        ball.z <= 90 &&
        distance <= Tuning.hitWindowRadius &&
        onHitterSide;
  }

  Vector2 _targetFor(
    ShotType shotType,
    PlayerSide side,
    PlayerState hitter,
    PlayerState opponent,
  ) {
    final spread = (_random.nextDouble() * 2 - 1) * 30;
    final x = (shotType == ShotType.drive)
        ? Court.width - hitter.position.x
        : opponent.position.x + spread;

    if (side == PlayerSide.player) {
      return Vector2(
        x.clamp(Court.left + 12, Court.right - 12).toDouble(),
        shotType == ShotType.dink ? 220 : 40,
      );
    }
    return Vector2(
      (x + (_random.nextDouble() * 2 - 1) * 18)
          .clamp(Court.left + 12, Court.right - 12)
          .toDouble(),
      shotType == ShotType.dink ? 260 : 430,
    );
  }

  void _applyShot(
    BallState ball,
    Vector2 target,
    PlayerSide hitterSide,
    ShotType shotType,
  ) {
    final start = Vector2(ball.x, ball.y);
    final delta = target - start;
    final speed = shotType == ShotType.dink
        ? Tuning.dinkSpeedXY
        : Tuning.driveSpeedXY;
    final gravityScale = shotType == ShotType.dink
        ? Tuning.dinkArcGravityScale
        : Tuning.driveArcGravityScale;
    final minVz = shotType == ShotType.dink
        ? Tuning.dinkInitialZ
        : Tuning.driveInitialZ;
    final time = math.max(delta.length / speed, 0.2);
    final gravity = Tuning.gravity * gravityScale;
    final solvedVz = (0 - ball.z + 0.5 * gravity * time * time) / time;

    ball.vx = delta.x / time;
    ball.vy = delta.y / time;
    ball.vz = math.max(minVz, solvedVz);
    ball.arcGravityScale = gravityScale;
    ball.lastHitBy = hitterSide;
    ball.hasBouncedThisSide = false;
    ball.isInPlay = true;
  }
}
