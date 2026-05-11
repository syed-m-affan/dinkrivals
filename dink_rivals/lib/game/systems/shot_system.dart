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
  double _playerHitCooldown = 0;
  double _opponentHitCooldown = 0;

  void update(double dt) {
    _playerHitCooldown = math.max(0, _playerHitCooldown - dt);
    _opponentHitCooldown = math.max(0, _opponentHitCooldown - dt);
  }

  /// Launches the ball from the racket tip toward `racketDirection` using
  /// fixed serve speed and lift. Used by the SERVE button so the serve is
  /// independent of swing-stick motion. See ticket P0-004.
  void serve({
    required BallState ball,
    required PlayerState hitter,
    required Vector2 racketDirection,
  }) {
    final dir = racketDirection.length2 > 0.01
        ? racketDirection.normalized()
        : (hitter.side == PlayerSide.player ? Vector2(0, -1) : Vector2(0, 1));
    ball.vx = dir.x * Tuning.serveMinOutputSpeed;
    ball.vy = dir.y * Tuning.serveMinOutputSpeed;
    ball.vz = Tuning.serveMinLift;
    ball.arcGravityScale = Tuning.serveArcGravityScale;
    ball.lastHitBy = hitter.side;
    ball.hasBouncedThisSide = false;
    ball.isInPlay = true;
    hitter.isSwinging = true;
    lastShotType = ShotType.serve;
    if (hitter.side == PlayerSide.player) {
      _playerHitCooldown = Tuning.racketHitCooldown;
    } else {
      _opponentHitCooldown = Tuning.racketHitCooldown;
    }
  }

  bool attemptRacketContact({
    required BallState ball,
    required PlayerState hitter,
    required Vector2 racketPosition,
    required Vector2 racketDirection,
    required Vector2 racketVelocity,
  }) {
    final cooldown = hitter.side == PlayerSide.player
        ? _playerHitCooldown
        : _opponentHitCooldown;
    if (cooldown > 0 ||
        !_isContactHittable(
          ball: ball,
          hitter: hitter,
          racketPosition: racketPosition,
        )) {
      return false;
    }

    final ballVelocity = Vector2(ball.vx, ball.vy);
    final sideForward =
        hitter.side == PlayerSide.player ? Vector2(0, -1) : Vector2(0, 1);
    final shaft = racketDirection.length2 > 0.01
        ? racketDirection.normalized()
        : sideForward.clone();

    final swingDir = Vector2.zero();
    final swingMinSq = Tuning.swingDirMinSpeed * Tuning.swingDirMinSpeed;
    if (racketVelocity.length2 > swingMinSq) {
      swingDir.setFrom(racketVelocity.normalized());
    }

    final reflectDir = Vector2.zero();
    var incomingFactor = 0.0;
    final ballSpeed = ballVelocity.length;
    if (ballSpeed > 0.1) {
      final d = ballVelocity / ballSpeed;
      reflectDir.setFrom(d - shaft * (2 * d.dot(shaft)));
      incomingFactor =
          (ballSpeed / Tuning.reflectFullSpeed).clamp(0.0, 1.0).toDouble();
    }

    final pushDir = Vector2.zero();
    final pushMinSq = Tuning.playerPushMinSpeed * Tuning.playerPushMinSpeed;
    if (hitter.velocity.length2 > pushMinSq) {
      pushDir.setFrom(hitter.velocity.normalized());
    }

    final outgoing = shaft * Tuning.dirShaftWeight +
        swingDir * Tuning.dirSwingWeight +
        reflectDir * (Tuning.dirReflectWeight * incomingFactor) +
        pushDir * Tuning.dirPushWeight;
    if (outgoing.length2 < 0.01) {
      outgoing.setFrom(sideForward);
    }
    outgoing.normalize();

    if (outgoing.dot(sideForward) < Tuning.backwardClampDot) {
      outgoing.y = sideForward.y * outgoing.y.abs();
      if (outgoing.length2 < 0.01) {
        outgoing.setFrom(sideForward);
      } else {
        outgoing.normalize();
      }
    }

    // `face` retained for shot classification (lob angle test).
    final face = shaft;

    final isServe = !ball.isInPlay;
    final swingSpeed = racketVelocity.length;
    final incomingSpeed = math.max(0, -ballVelocity.dot(outgoing));
    final playerPush = math.max(0, hitter.velocity.dot(outgoing));
    final contactSpeed = swingSpeed + incomingSpeed;
    if (contactSpeed < Tuning.minRacketContactSpeed) {
      return false;
    }

    var outputSpeed = (swingSpeed * Tuning.swingPowerScale +
            incomingSpeed * Tuning.incomingPowerScale +
            playerPush * Tuning.playerPushScale)
        .clamp(Tuning.softContactSpeed, Tuning.firmContactSpeed)
        .toDouble();
    if (isServe) {
      outputSpeed = math.max(outputSpeed, Tuning.serveMinOutputSpeed);
    }
    final shotType = _classifyContact(
      ball: ball,
      face: face,
      contactSpeed: contactSpeed,
      outputSpeed: outputSpeed,
    );
    final adjustedSpeed = _speedForContact(shotType, outputSpeed);
    ball.vx = outgoing.x * adjustedSpeed;
    ball.vy = outgoing.y * adjustedSpeed;
    ball.vz = _liftForContact(shotType, adjustedSpeed);
    if (isServe && shotType != ShotType.lob && shotType != ShotType.smash) {
      ball.vz = math.max(ball.vz, Tuning.serveMinLift);
    }
    ball.arcGravityScale = _gravityScaleForContact(shotType);
    ball.lastHitBy = hitter.side;
    ball.hasBouncedThisSide = false;
    ball.isInPlay = true;
    hitter.isSwinging = true;
    lastShotType = shotType;

    if (hitter.side == PlayerSide.player) {
      _playerHitCooldown = Tuning.racketHitCooldown;
    } else {
      _opponentHitCooldown = Tuning.racketHitCooldown;
    }
    return true;
  }

  bool attemptShot({
    required BallState ball,
    required PlayerState hitter,
    required PlayerState opponent,
    required ShotType shotType,
    Vector2? aim,
  }) {
    if (!_isHittable(ball, hitter, aim)) {
      hitter.isSwinging = true;
      return false;
    }

    final target = _targetFor(shotType, hitter.side);
    _applyShot(ball, target, hitter.side, shotType);
    hitter.isSwinging = true;
    lastShotType = shotType;
    return true;
  }

  ShotType _classifyContact({
    required BallState ball,
    required Vector2 face,
    required double contactSpeed,
    required double outputSpeed,
  }) {
    if (ball.z >= Tuning.smashMinBallHeight &&
        contactSpeed >= Tuning.smashContactSpeed) {
      return ShotType.smash;
    }
    if (face.x.abs() >= Tuning.lobAngleThreshold &&
        outputSpeed < Tuning.driveContactThreshold) {
      return ShotType.lob;
    }
    if (outputSpeed >= Tuning.driveContactThreshold) {
      return ShotType.drive;
    }
    return ShotType.dink;
  }

  double _speedForContact(ShotType shotType, double outputSpeed) {
    switch (shotType) {
      case ShotType.lob:
        return math.max(outputSpeed, Tuning.lobSpeedXY);
      case ShotType.smash:
        return math.max(outputSpeed, Tuning.smashSpeedXY);
      case ShotType.block:
      case ShotType.serve:
      case ShotType.dink:
      case ShotType.drive:
        return outputSpeed;
    }
  }

  double _liftForContact(ShotType shotType, double outputSpeed) {
    switch (shotType) {
      case ShotType.lob:
        return Tuning.lobInitialZ;
      case ShotType.smash:
        return Tuning.smashInitialZ;
      case ShotType.block:
      case ShotType.serve:
      case ShotType.dink:
      case ShotType.drive:
        return math.max(
          Tuning.contactLiftBase,
          Tuning.contactLiftBase + outputSpeed * Tuning.contactLiftScale,
        );
    }
  }

  double _gravityScaleForContact(ShotType shotType) {
    switch (shotType) {
      case ShotType.lob:
        return Tuning.lobArcGravityScale;
      case ShotType.smash:
        return Tuning.smashArcGravityScale;
      case ShotType.drive:
        return Tuning.driveArcGravityScale;
      case ShotType.block:
      case ShotType.serve:
      case ShotType.dink:
        return Tuning.dinkArcGravityScale;
    }
  }

  bool _isContactHittable({
    required BallState ball,
    required PlayerState hitter,
    required Vector2 racketPosition,
  }) {
    final ballPosition = Vector2(ball.x, ball.y);
    final distance = _distanceToSegment(
      point: ballPosition,
      start: hitter.position,
      end: racketPosition,
    );
    final onHitterSide = hitter.side == PlayerSide.player
        ? ball.y >= Court.netY
        : ball.y <= Court.netY;
    final validHeight = ball.z >= 0 && ball.z <= 90;
    return validHeight && distance <= Tuning.racketHitRadius && onHitterSide;
  }

  double _distanceToSegment({
    required Vector2 point,
    required Vector2 start,
    required Vector2 end,
  }) {
    final segment = end - start;
    final lengthSquared = segment.length2;
    if (lengthSquared <= 0.0001) {
      return point.distanceTo(start);
    }
    final t = ((point - start).dot(segment) / lengthSquared)
        .clamp(0.0, 1.0)
        .toDouble();
    final closest = start + segment * t;
    return point.distanceTo(closest);
  }

  bool _isHittable(BallState ball, PlayerState hitter, Vector2? aim) {
    final ballPosition = Vector2(ball.x, ball.y);
    final racketPosition = _racketPositionFor(ball, hitter, aim);
    final distance = racketPosition.distanceTo(ballPosition);
    final onHitterSide = hitter.side == PlayerSide.player
        ? ball.y >= Court.netY
        : ball.y <= Court.netY;
    final validHeight = ball.z >= 0 && ball.z <= 90;
    return validHeight && distance <= Tuning.racketHitRadius && onHitterSide;
  }

  Vector2 _racketPositionFor(BallState ball, PlayerState hitter, Vector2? aim) {
    final defaultY = hitter.side == PlayerSide.player ? -1.0 : 1.0;
    final direction = Vector2(aim?.x ?? 0, aim?.y ?? defaultY);
    if (direction.length2 < 0.01) {
      direction.setValues(0, defaultY);
    }
    if (hitter.side == PlayerSide.opponent) {
      direction.setValues(
          ball.x - hitter.position.x, ball.y - hitter.position.y);
      if (direction.length2 < 0.01) {
        direction.setValues(0, defaultY);
      }
    }
    direction.normalize();
    return hitter.position + direction * Tuning.racketReach;
  }

  Vector2 _targetFor(ShotType shotType, PlayerSide side) {
    final x = (Court.width / 2 +
            (_random.nextDouble() * 2 - 1) * Tuning.opponentTargetJitter)
        .clamp(Court.left + 12, Court.right - 12)
        .toDouble();
    if (side == PlayerSide.player) {
      return Vector2(
        x,
        switch (shotType) {
          ShotType.dink || ShotType.block => 218,
          ShotType.lob || ShotType.drive || ShotType.serve => 54,
          ShotType.smash => 36,
        },
      );
    }
    return Vector2(
      x,
      switch (shotType) {
        ShotType.dink || ShotType.block => 262,
        ShotType.lob || ShotType.drive || ShotType.serve => 392,
        ShotType.smash => 420,
      },
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
    final speed = switch (shotType) {
      ShotType.dink || ShotType.block => Tuning.dinkSpeedXY,
      ShotType.lob => Tuning.lobSpeedXY,
      ShotType.smash => Tuning.smashSpeedXY,
      ShotType.drive || ShotType.serve => Tuning.driveSpeedXY,
    };
    final gravityScale = _gravityScaleForContact(shotType);
    final minVz = switch (shotType) {
      ShotType.dink || ShotType.block => Tuning.dinkInitialZ,
      ShotType.lob => Tuning.lobInitialZ,
      ShotType.smash => Tuning.smashInitialZ,
      ShotType.drive || ShotType.serve => Tuning.driveInitialZ,
    };
    final rawTime = math.max(delta.length / speed, 0.2);
    final time = shotType == ShotType.dink
        ? rawTime.clamp(0.68, 0.96).toDouble()
        : rawTime.clamp(0.62, 0.9).toDouble();
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
