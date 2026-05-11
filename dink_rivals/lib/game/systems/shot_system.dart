import 'dart:math' as math;

import 'package:flame/components.dart';

import '../config/court_constants.dart';
import '../config/tuning_constants.dart';
import '../models/ball_state.dart';
import '../models/player_side.dart';
import '../models/player_state.dart';
import '../models/shot_type.dart';
import '../models/swing_intent.dart';

enum ContactQuality { clean, forgiven, emergency, miss }

enum BallHeightBand { low, mid, smashable }

class ContactProfile {
  const ContactProfile(this.quality, this.heightBand);

  final ContactQuality quality;
  final BallHeightBand heightBand;

  bool get didHit => quality != ContactQuality.miss;
}

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
    double power = 0,
  }) {
    final dir = racketDirection.length2 > 0.01
        ? racketDirection.normalized()
        : (hitter.side == PlayerSide.player ? Vector2(0, -1) : Vector2(0, 1));
    final servePower = power.clamp(0.0, 1.0).toDouble();
    final outputSpeed = Tuning.serveMinOutputSpeed +
        (Tuning.serveMaxOutputSpeed - Tuning.serveMinOutputSpeed) * servePower;
    final lift = Tuning.serveMinLift +
        (Tuning.serveMaxLift - Tuning.serveMinLift) * servePower;
    ball.vx = dir.x * outputSpeed;
    ball.vy = dir.y * outputSpeed;
    ball.vz = lift;
    ball.arcGravityScale = Tuning.serveArcGravityScale;
    ball.lastHitBy = hitter.side;
    ball.hasBouncedThisSide = false;
    ball.isInPlay = true;
    hitter.isSwinging = true;
    hitter.lastShotType = ShotType.serve;
    lastShotType = ShotType.serve;
    _setCooldown(hitter.side);
  }

  bool attemptManualContact({
    required BallState ball,
    required PlayerState hitter,
    required Vector2 racketPosition,
    required Vector2 aimDirection,
    SwingIntent? intent,
    double power = 0,
  }) {
    if (_cooldownFor(hitter.side) > 0) {
      return false;
    }
    final contact = _contactProfile(
      ball: ball,
      hitter: hitter,
      racketPosition: racketPosition,
    );
    if (!contact.didHit) {
      return false;
    }

    final shotIntent = intent ?? SwingIntent.dink;
    final shotPower = intent == null ? 0.16 : power;
    final shotType = _shotTypeForIntent(shotIntent, contact);
    _applyProfiledShot(
      ball: ball,
      hitterSide: hitter.side,
      shotType: shotType,
      aimDirection: aimDirection,
      power: shotPower,
      quality: contact.quality,
    );
    hitter.isSwinging = true;
    hitter.lastShotType = shotType;
    lastShotType = shotType;
    _setCooldown(hitter.side);
    return true;
  }

  bool attemptRacketContact({
    required BallState ball,
    required PlayerState hitter,
    required Vector2 racketPosition,
    required Vector2 racketDirection,
    required Vector2 racketVelocity,
  }) {
    if (_cooldownFor(hitter.side) > 0) {
      return false;
    }
    final contact = _contactProfile(
      ball: ball,
      hitter: hitter,
      racketPosition: racketPosition,
    );
    if (!contact.didHit) {
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

    final swingSpeed = racketVelocity.length;
    final incomingSpeed = math.max(0, -ballVelocity.dot(outgoing));
    final playerPush = math.max(0, hitter.velocity.dot(outgoing));
    final contactSpeed = swingSpeed + incomingSpeed;
    if (contactSpeed < Tuning.minRacketContactSpeed &&
        contact.quality != ContactQuality.emergency) {
      return false;
    }

    final outputSpeed = (swingSpeed * Tuning.swingPowerScale +
            incomingSpeed * Tuning.incomingPowerScale +
            playerPush * Tuning.playerPushScale)
        .clamp(Tuning.softContactSpeed, Tuning.firmContactSpeed)
        .toDouble();
    final intent = _intentForClassicContact(
      ball: ball,
      face: shaft,
      contactSpeed: contactSpeed,
      outputSpeed: outputSpeed,
    );
    final shotType = _shotTypeForIntent(intent, contact);
    final power = ((outputSpeed - Tuning.softContactSpeed) /
            (Tuning.firmContactSpeed - Tuning.softContactSpeed))
        .clamp(0.0, 1.0)
        .toDouble();
    _applyProfiledShot(
      ball: ball,
      hitterSide: hitter.side,
      shotType: shotType,
      aimDirection: outgoing,
      power: power,
      quality: contact.quality,
    );
    hitter.isSwinging = true;
    hitter.lastShotType = shotType;
    lastShotType = shotType;
    _setCooldown(hitter.side);
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

    final aimDirection = _aimDirectionFor(ball, hitter, aim);
    _applyProfiledShot(
      ball: ball,
      hitterSide: hitter.side,
      shotType: shotType,
      aimDirection: aimDirection,
      power: 0.72,
      quality: ContactQuality.clean,
    );
    hitter.isSwinging = true;
    hitter.lastShotType = shotType;
    lastShotType = shotType;
    _setCooldown(hitter.side);
    return true;
  }

  double _cooldownFor(PlayerSide side) {
    return side == PlayerSide.player
        ? _playerHitCooldown
        : _opponentHitCooldown;
  }

  void _setCooldown(PlayerSide side) {
    if (side == PlayerSide.player) {
      _playerHitCooldown = Tuning.racketHitCooldown;
    } else {
      _opponentHitCooldown = Tuning.racketHitCooldown;
    }
  }

  ContactProfile _contactProfile({
    required BallState ball,
    required PlayerState hitter,
    required Vector2 racketPosition,
  }) {
    final onHitterSide = hitter.side == PlayerSide.player
        ? ball.y >= Court.netY
        : ball.y <= Court.netY;
    if (!onHitterSide || ball.z < 0 || ball.z > Tuning.playableBallMaxZ) {
      return ContactProfile(ContactQuality.miss, _heightBand(ball));
    }

    final ballPosition = Vector2(ball.x, ball.y);
    final shaft = racketPosition - hitter.position;
    final racketStart = shaft.length2 > 0.01
        ? hitter.position + shaft.normalized() * (Tuning.racketReach * 0.45)
        : hitter.position.clone();
    final racketDistance = _distanceToSegment(
      point: ballPosition,
      start: racketStart,
      end: racketPosition,
    );
    if (racketDistance <= Tuning.cleanContactRadius) {
      return ContactProfile(ContactQuality.clean, _heightBand(ball));
    }
    if (!ball.isInPlay) {
      return ContactProfile(ContactQuality.miss, _heightBand(ball));
    }
    if (racketDistance <= Tuning.forgivenContactRadius) {
      return ContactProfile(ContactQuality.forgiven, _heightBand(ball));
    }

    final bodyDistance = ballPosition.distanceTo(hitter.position);
    final incomingSpeed = Vector2(ball.vx, ball.vy).length;
    final canEmergencyBlock = ball.isInPlay &&
        ball.lastHitBy != hitter.side &&
        ball.z <= Tuning.lowBallMaxZ + 12 &&
        incomingSpeed <= Tuning.firmContactSpeed;
    if (canEmergencyBlock &&
        bodyDistance <= Tuning.emergencyBodyContactRadius) {
      return ContactProfile(ContactQuality.emergency, _heightBand(ball));
    }
    return ContactProfile(ContactQuality.miss, _heightBand(ball));
  }

  BallHeightBand _heightBand(BallState ball) {
    if (ball.z <= Tuning.lowBallMaxZ) {
      return BallHeightBand.low;
    }
    if (ball.z >= Tuning.smashableBallMinZ) {
      return BallHeightBand.smashable;
    }
    return BallHeightBand.mid;
  }

  SwingIntent _intentForClassicContact({
    required BallState ball,
    required Vector2 face,
    required double contactSpeed,
    required double outputSpeed,
  }) {
    if (ball.z >= Tuning.smashableBallMinZ &&
        contactSpeed >= Tuning.smashContactSpeed) {
      return SwingIntent.smash;
    }
    if (face.x.abs() >= Tuning.lobAngleThreshold &&
        outputSpeed < Tuning.driveContactThreshold) {
      return SwingIntent.lob;
    }
    if (outputSpeed >= Tuning.driveContactThreshold) {
      return SwingIntent.drive;
    }
    return SwingIntent.dink;
  }

  ShotType _shotTypeForIntent(SwingIntent intent, ContactProfile contact) {
    if (contact.quality == ContactQuality.emergency) {
      return ShotType.block;
    }
    if (contact.quality == ContactQuality.forgiven &&
        intent == SwingIntent.smash) {
      return ShotType.drive;
    }
    return switch (intent) {
      SwingIntent.dink => ShotType.dink,
      SwingIntent.drive => ShotType.drive,
      SwingIntent.lob => ShotType.lob,
      SwingIntent.smash => contact.heightBand == BallHeightBand.smashable
          ? ShotType.smash
          : ShotType.drive,
    };
  }

  void _applyProfiledShot({
    required BallState ball,
    required PlayerSide hitterSide,
    required ShotType shotType,
    required Vector2 aimDirection,
    required double power,
    required ContactQuality quality,
  }) {
    final adjustedPower = switch (quality) {
      ContactQuality.clean => power,
      ContactQuality.forgiven => power * Tuning.forgivenShotPowerScale,
      ContactQuality.emergency => power * Tuning.emergencyShotPowerScale,
      ContactQuality.miss => 0.0,
    }
        .clamp(0.0, 1.0)
        .toDouble();
    final target = _targetForProfile(
      shotType: shotType,
      side: hitterSide,
      aimDirection: aimDirection,
      power: adjustedPower,
      quality: quality,
    );
    _applyShot(ball, target, hitterSide, shotType, adjustedPower);
  }

  Vector2 _targetForProfile({
    required ShotType shotType,
    required PlayerSide side,
    required Vector2 aimDirection,
    required double power,
    required ContactQuality quality,
  }) {
    final aim = _sideCorrectedAim(aimDirection, side);
    final lateralRange = switch (quality) {
      ContactQuality.clean => Court.width * 0.42,
      ContactQuality.forgiven => Court.width * 0.28,
      ContactQuality.emergency => Court.width * 0.14,
      ContactQuality.miss => 0.0,
    };
    final jitter = quality == ContactQuality.clean
        ? (_random.nextDouble() * 2 - 1) * 5
        : 0.0;
    final x = (Court.width / 2 + aim.x * lateralRange + jitter)
        .clamp(Court.left + 12, Court.right - 12)
        .toDouble();
    final depth = (-aim.y * side.sign).clamp(0.0, 1.0).toDouble();

    if (side == PlayerSide.player) {
      return Vector2(
        x,
        switch (shotType) {
          ShotType.dink || ShotType.block => _lerp(228, 204, power),
          ShotType.drive || ShotType.serve => _lerp(148, 58, depth),
          ShotType.lob => 132,
          ShotType.smash => 36,
        },
      );
    }
    return Vector2(
      x,
      switch (shotType) {
        ShotType.dink || ShotType.block => _lerp(252, 276, power),
        ShotType.drive || ShotType.serve => _lerp(332, 422, depth),
        ShotType.lob => 348,
        ShotType.smash => 444,
      },
    );
  }

  Vector2 _sideCorrectedAim(Vector2 aimDirection, PlayerSide side) {
    final defaultY = side == PlayerSide.player ? -1.0 : 1.0;
    final aim = aimDirection.length2 > 0.01
        ? aimDirection.normalized()
        : Vector2(0, defaultY);
    if (side == PlayerSide.player && aim.y > -0.12) {
      aim.y = -0.12;
    } else if (side == PlayerSide.opponent && aim.y < 0.12) {
      aim.y = 0.12;
    }
    aim.normalize();
    return aim;
  }

  void _applyShot(
    BallState ball,
    Vector2 target,
    PlayerSide hitterSide,
    ShotType shotType,
    double power,
  ) {
    final start = Vector2(ball.x, ball.y);
    final delta = target - start;
    final speed = _speedForProfile(shotType, power);
    final gravityScale = _gravityScaleForContact(shotType);
    final minVz = switch (shotType) {
      ShotType.dink || ShotType.block => Tuning.dinkInitialZ,
      ShotType.lob => Tuning.lobInitialZ,
      ShotType.smash => Tuning.smashInitialZ,
      ShotType.drive || ShotType.serve => Tuning.driveInitialZ,
    };
    final rawTime = math.max(delta.length / speed, 0.2);
    final time = switch (shotType) {
      ShotType.dink || ShotType.block => rawTime.clamp(0.70, 1.02).toDouble(),
      ShotType.lob => rawTime.clamp(0.92, 1.26).toDouble(),
      ShotType.smash => rawTime.clamp(0.46, 0.70).toDouble(),
      ShotType.drive || ShotType.serve => rawTime.clamp(0.58, 0.88).toDouble(),
    };
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

  double _speedForProfile(ShotType shotType, double power) {
    return switch (shotType) {
      ShotType.dink =>
        _lerp(Tuning.dinkSpeedXY * 0.82, Tuning.dinkSpeedXY, power),
      ShotType.block => Tuning.dinkSpeedXY * 0.72,
      ShotType.lob => _lerp(Tuning.lobSpeedXY * 0.88, Tuning.lobSpeedXY, power),
      ShotType.smash =>
        _lerp(Tuning.smashSpeedXY * 0.92, Tuning.smashSpeedXY * 1.08, power),
      ShotType.drive ||
      ShotType.serve =>
        _lerp(Tuning.driveSpeedXY * 0.88, Tuning.driveSpeedXY * 1.16, power),
    };
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

  bool _isHittable(BallState ball, PlayerState hitter, Vector2? aim) {
    final contact = _contactProfile(
      ball: ball,
      hitter: hitter,
      racketPosition: _racketPositionFor(ball, hitter, aim),
    );
    return contact.didHit;
  }

  Vector2 _racketPositionFor(BallState ball, PlayerState hitter, Vector2? aim) {
    final direction = _aimDirectionFor(ball, hitter, aim);
    return hitter.position + direction * Tuning.racketReach;
  }

  Vector2 _aimDirectionFor(BallState ball, PlayerState hitter, Vector2? aim) {
    final defaultY = hitter.side == PlayerSide.player ? -1.0 : 1.0;
    final direction = Vector2(aim?.x ?? 0, aim?.y ?? defaultY);
    if (direction.length2 < 0.01) {
      direction.setValues(0, defaultY);
    }
    if (hitter.side == PlayerSide.opponent) {
      direction.setValues(
        ball.x - hitter.position.x,
        ball.y - hitter.position.y,
      );
      if (direction.length2 < 0.01) {
        direction.setValues(0, defaultY);
      }
    }
    direction.normalize();
    return direction;
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

  double _lerp(double a, double b, double t) {
    return a + (b - a) * t.clamp(0.0, 1.0).toDouble();
  }
}

extension on PlayerSide {
  double get sign => this == PlayerSide.player ? 1 : -1;
}
