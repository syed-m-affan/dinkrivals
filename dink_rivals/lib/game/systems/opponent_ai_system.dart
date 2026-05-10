import 'dart:math' as math;

import 'package:flame/components.dart';

import '../config/court_constants.dart';
import '../config/tuning_constants.dart';
import '../models/ball_state.dart';
import '../models/player_state.dart';
import '../models/shot_type.dart';
import 'shot_system.dart';

class OpponentAISystem {
  OpponentAISystem({math.Random? random}) : _random = random ?? math.Random();

  final math.Random _random;
  double _reactionTimer = 0;
  Vector2 _target = Vector2(Court.opponentStartX, Court.opponentStartY);

  void update({
    required BallState ball,
    required PlayerState opponent,
    required PlayerState player,
    required ShotSystem shotSystem,
    required double dt,
  }) {
    _reactionTimer -= dt;
    if (_reactionTimer <= 0) {
      _target = _predictLanding(ball);
      _reactionTimer = Tuning.opponentReactionDelaySec;
    }

    final toTarget = _target - opponent.position;
    if (toTarget.length > 1) {
      toTarget.normalize();
      opponent.velocity.setFrom(toTarget * Tuning.opponentMaxSpeed);
      opponent.position.add(opponent.velocity * dt);
      opponent.position.x = opponent.position.x.clamp(Court.left, Court.right).toDouble();
      opponent.position.y = opponent.position.y.clamp(Court.top, Court.netY).toDouble();
    } else {
      opponent.velocity.setZero();
    }

    final shotType = _random.nextDouble() < Tuning.opponentDinkProbability
        ? ShotType.dink
        : ShotType.drive;
    if (_random.nextDouble() < Tuning.opponentMissChance) {
      return;
    }
    shotSystem.attemptShot(
      ball: ball,
      hitter: opponent,
      opponent: player,
      shotType: shotType,
    );
  }

  Vector2 _predictLanding(BallState ball) {
    var x = ball.x;
    var y = ball.y;
    var z = ball.z;
    var vx = ball.vx;
    var vy = ball.vy;
    var vz = ball.vz;
    const step = 0.05;

    for (var t = 0.0; t < 2.5; t += step) {
      vx *= 1 - Tuning.airDrag * step;
      vy *= 1 - Tuning.airDrag * step;
      vz -= Tuning.gravity * ball.arcGravityScale * step;
      x += vx * step;
      y += vy * step;
      z += vz * step;
      if (z <= 0 && y <= Court.netY) {
        break;
      }
    }

    return Vector2(
      x.clamp(Court.left + 8, Court.right - 8).toDouble(),
      y.clamp(Court.top + 8, Court.netY - 8).toDouble(),
    );
  }
}
