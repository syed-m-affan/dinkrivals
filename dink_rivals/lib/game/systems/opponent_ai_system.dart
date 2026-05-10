import 'dart:math' as math;

import 'package:flame/components.dart';

import '../config/court_constants.dart';
import '../config/tuning_constants.dart';
import '../models/ball_state.dart';
import '../models/player_side.dart';
import '../models/player_state.dart';
import '../models/shot_type.dart';
import 'shot_system.dart';

class OpponentAISystem {
  OpponentAISystem({math.Random? random}) : _random = random ?? math.Random();

  final math.Random _random;
  double _reactionTimer = 0;
  double _idleTimer = 0;
  Vector2 _target = Vector2(Court.opponentStartX, Court.opponentStartY);
  bool _missedCurrentReturn = false;

  void update({
    required BallState ball,
    required PlayerState opponent,
    required PlayerState player,
    required ShotSystem shotSystem,
    required double dt,
  }) {
    _idleTimer += dt;
    if (ball.currentSide != PlayerSide.opponent ||
        ball.lastHitBy == PlayerSide.opponent) {
      _missedCurrentReturn = false;
    }

    _reactionTimer -= dt;
    if (_reactionTimer <= 0) {
      _target =
          _shouldDefend(ball) ? _predictLanding(ball) : _readyPosition(ball);
      _reactionTimer = Tuning.opponentReactionDelaySec;
    }

    final toTarget = _target - opponent.position;
    if (toTarget.length > 1) {
      toTarget.normalize();
      opponent.velocity.setFrom(toTarget * Tuning.opponentMaxSpeed);
      opponent.position.add(opponent.velocity * dt);
      opponent.position.x =
          opponent.position.x.clamp(Court.left, Court.right).toDouble();
      opponent.position.y =
          opponent.position.y.clamp(Court.top, Court.netY).toDouble();
    } else {
      opponent.velocity.setZero();
    }

    if (_missedCurrentReturn || !ball.isInPlay || !_shouldDefend(ball)) {
      return;
    }

    final shotType =
        _chooseShot(ball: ball, opponent: opponent, player: player);
    final attempted = shotSystem.attemptShot(
      ball: ball,
      hitter: opponent,
      opponent: player,
      shotType: shotType,
    );
    if (attempted && _random.nextDouble() < Tuning.opponentMissChance) {
      ball.lastHitBy = player.side;
      ball.vx *= 0.65;
      ball.vy *= 0.65;
      ball.vz *= 0.8;
      _missedCurrentReturn = true;
    }
  }

  ShotType _chooseShot({
    required BallState ball,
    required PlayerState opponent,
    required PlayerState player,
  }) {
    if (ball.z >= Tuning.smashMinBallHeight && _random.nextDouble() < 0.55) {
      return ShotType.smash;
    }
    final opponentNearKitchen =
        opponent.position.y >= Court.opponentKitchenTopY - 18;
    final playerNearKitchen =
        player.position.y <= Court.playerKitchenBottomY + 22;
    if ((opponentNearKitchen || playerNearKitchen) &&
        _random.nextDouble() < 0.28) {
      return ShotType.lob;
    }
    return _random.nextDouble() < Tuning.opponentDinkProbability
        ? ShotType.dink
        : ShotType.drive;
  }

  bool _shouldDefend(BallState ball) {
    if (!ball.isInPlay || ball.lastHitBy == PlayerSide.opponent) {
      return false;
    }
    return ball.currentSide == PlayerSide.opponent || ball.vy < 0;
  }

  Vector2 _readyPosition(BallState ball) {
    final sway = math.sin(_idleTimer * 0.65) * 7;
    final creep = math.sin(_idleTimer * 0.48) * 3;
    final shadeX = (ball.x * 0.35 + Court.width * 0.65 / 2)
        .clamp(Court.left + 24, Court.right - 24)
        .toDouble();
    return Vector2(
      (shadeX + sway).clamp(Court.left + 24, Court.right - 24).toDouble(),
      92 + creep,
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
