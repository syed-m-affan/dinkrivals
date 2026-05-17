import 'dart:math' as math;

import 'package:flame/components.dart';

import '../config/court_constants.dart';
import '../config/tuning_constants.dart';
import '../models/ball_state.dart';
import '../models/match_state.dart';
import '../models/opponent_ai_profile.dart';
import '../models/player_side.dart';
import '../models/player_state.dart';
import '../models/shot_type.dart';
import 'shot_system.dart';

class OpponentAISystem {
  OpponentAISystem({
    math.Random? random,
    OpponentAiProfile? profile,
  })  : _random = random ?? math.Random(),
        _profile = profile ?? defaultProfile;

  static const defaultProfile = OpponentAiProfile(
    id: 'quick_match',
    displayName: 'Quick Match Rival',
    maxSpeed: Tuning.opponentMaxSpeed,
    whiffChance: Tuning.opponentWhiffChance,
    dinkProbability: Tuning.opponentDinkProbability,
    lobProbability: Tuning.opponentLobProbability,
    smashProbability: Tuning.opponentSmashProbability,
  );

  final math.Random _random;
  OpponentAiProfile _profile;
  double _reactionTimer = 0;
  double _idleTimer = 0;
  Vector2 _target = Vector2(Court.opponentStartX, Court.opponentStartY);
  bool _missedCurrentReturn = false;
  bool _whiffDecidedThisDefense = false;

  OpponentAiProfile get profile => _profile;

  void setProfile(OpponentAiProfile profile) {
    _profile = profile;
  }

  void update({
    required BallState ball,
    required MatchState matchState,
    required PlayerState opponent,
    required PlayerState player,
    required ShotSystem shotSystem,
    required double dt,
  }) {
    _idleTimer += dt;
    if (ball.currentSide != PlayerSide.opponent ||
        ball.lastHitBy == PlayerSide.opponent) {
      _missedCurrentReturn = false;
      _whiffDecidedThisDefense = false;
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
      opponent.velocity.setFrom(toTarget * _profile.maxSpeed);
      opponent.position.add(opponent.velocity * dt);
      opponent.position.x =
          opponent.position.x.clamp(Court.left, Court.right).toDouble();
      // Hold opponent at least 60 units back from the net. Inside that band
      // the racket grabs the ball when ball.y is already ≈ Court.netY, leaving
      // no horizontal distance for a forward shot to arc above the net.
      opponent.position.y =
          opponent.position.y.clamp(Court.top, Court.netY - 60).toDouble();
    } else {
      opponent.velocity.setZero();
    }

    if (_missedCurrentReturn ||
        !ball.isInPlay ||
        !_shouldDefend(ball) ||
        !_canAttemptReturn(matchState: matchState, opponent: opponent)) {
      return;
    }

    // Decide whiff exactly once per defense opportunity, not every frame.
    if (!_whiffDecidedThisDefense) {
      _whiffDecidedThisDefense = true;
      if (_random.nextDouble() < _profile.whiffChance) {
        _missedCurrentReturn = true;
        return;
      }
    }

    final shotType =
        _chooseShot(ball: ball, opponent: opponent, player: player);
    final aim = _chooseAim(opponent: opponent, player: player);
    shotSystem.attemptShot(
      ball: ball,
      hitter: opponent,
      opponent: player,
      shotType: shotType,
      aim: aim,
    );
  }

  ShotType _chooseShot({
    required BallState ball,
    required PlayerState opponent,
    required PlayerState player,
  }) {
    final distanceToNet = (opponent.position.y - Court.netY).abs();
    final inKitchen = distanceToNet <= Court.kitchenDepth + 12;
    final isDeep = distanceToNet > Court.kitchenDepth + 30;

    if (ball.z >= Tuning.opponentSmashMinBallHeight &&
        inKitchen &&
        _random.nextDouble() < _profile.smashProbability) {
      return ShotType.smash;
    }
    if (isDeep) {
      // From back court a dink physically cannot reach the kitchen; drive only.
      return ShotType.drive;
    }
    final playerNearKitchen =
        player.position.y <= Court.playerKitchenBottomY + 22;
    if (playerNearKitchen && _random.nextDouble() < _profile.lobProbability) {
      return ShotType.lob;
    }
    return _random.nextDouble() < _profile.dinkProbability
        ? ShotType.dink
        : ShotType.drive;
  }

  Vector2 _chooseAim({
    required PlayerState opponent,
    required PlayerState player,
  }) {
    // Aim forward (toward player side) with a lateral bias away from where
    // the player currently is, so returns force them to move.
    final playerOffset =
        ((player.position.x - Court.width / 2) / (Court.width / 2 - 12))
            .clamp(-1.0, 1.0)
            .toDouble();
    final lateral = -playerOffset * 0.65;
    // Jitter so the AI doesn't hit the exact same spot on identical states.
    final jitter = (_random.nextDouble() * 2 - 1) * 0.18;
    final aim = Vector2(lateral + jitter, 1.0);
    aim.normalize();
    return aim;
  }

  bool _shouldDefend(BallState ball) {
    if (!ball.isInPlay || ball.lastHitBy == PlayerSide.opponent) {
      return false;
    }
    return ball.currentSide == PlayerSide.opponent || ball.vy < 0;
  }

  bool _canAttemptReturn({
    required MatchState matchState,
    required PlayerState opponent,
  }) {
    if (!matchState.pointInProgress || matchState.twoBounceRuleSatisfied) {
      return true;
    }
    return matchState.hasCourtBounce(opponent.side);
  }

  Vector2 _readyPosition(BallState ball) {
    final sway = math.sin(_idleTimer * 1.6) * 22;
    final drift = math.sin(_idleTimer * 0.55) * 14;
    final bob = math.sin(_idleTimer * 0.9) * 8;
    final shadeX = (ball.x * 0.35 + Court.width * 0.65 / 2)
        .clamp(Court.left + 24, Court.right - 24)
        .toDouble();
    return Vector2(
      (shadeX + sway + drift)
          .clamp(Court.left + 24, Court.right - 24)
          .toDouble(),
      (92 + bob).clamp(Court.top + 18, Court.netY - 30).toDouble(),
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
      y.clamp(Court.top + 8, Court.netY - 60).toDouble(),
    );
  }
}
