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

class SwingPath {
  const SwingPath(this.start, this.end);

  final Vector2 start;
  final Vector2 end;
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
    Vector2? swipeDirection,
    SwingIntent? intent,
    double power = 0,
    double swingSpeed = 0,
  }) {
    if (_cooldownFor(hitter.side) > 0) {
      return false;
    }
    if (_isOwnLiveBallBeforeBounce(ball, hitter)) {
      return false;
    }
    final shotIntent = intent ?? SwingIntent.dink;
    final contact = shotIntent == SwingIntent.dink
        ? _dinkBodyContactProfile(ball: ball, hitter: hitter)
        : _committedSwingContactProfile(
            ball: ball,
            hitter: hitter,
            intent: intent,
            swipeDirection: swipeDirection ?? aimDirection,
          );
    if (!contact.didHit) {
      return false;
    }

    final swingPower = _powerFromSwing(swingSpeed);
    final shotPower = intent == null
        ? math.max(0.16, swingPower * 0.6)
        : math.max(power, swingPower);
    final shotType = _shotTypeForIntent(shotIntent, contact);
    _applyProfiledShot(
      ball: ball,
      hitterSide: hitter.side,
      shotType: shotType,
      aimDirection: shotIntent == SwingIntent.dink
          ? aimDirection
          : _committedSwingAim(
              ball: ball,
              hitter: hitter,
              intent: shotIntent,
              swipeDirection: swipeDirection ?? aimDirection,
            ),
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
    if (_isOwnLiveBallBeforeBounce(ball, hitter)) {
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
    if (!_isHittable(ball, hitter, shotType, aim)) {
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

  ContactProfile _dinkBodyContactProfile({
    required BallState ball,
    required PlayerState hitter,
  }) {
    final onHitterSide = hitter.side == PlayerSide.player
        ? ball.y >= Court.netY
        : ball.y <= Court.netY;
    if (!onHitterSide || ball.z < 0 || ball.z > Tuning.playableBallMaxZ) {
      return ContactProfile(ContactQuality.miss, _heightBand(ball));
    }

    final bodyDistance = Vector2(ball.x, ball.y).distanceTo(hitter.position);
    if (bodyDistance <= Tuning.dinkBodyContactRadius) {
      return ContactProfile(ContactQuality.clean, _heightBand(ball));
    }
    return ContactProfile(ContactQuality.miss, _heightBand(ball));
  }

  ContactProfile _committedSwingContactProfile({
    required BallState ball,
    required PlayerState hitter,
    required SwingIntent? intent,
    required Vector2 swipeDirection,
  }) {
    final onHitterSide = hitter.side == PlayerSide.player
        ? ball.y >= Court.netY
        : ball.y <= Court.netY;
    if (!onHitterSide || ball.z < 0 || ball.z > Tuning.playableBallMaxZ) {
      return ContactProfile(ContactQuality.miss, _heightBand(ball));
    }

    final path = committedSwingPath(
      hitter: hitter,
      intent: intent ?? SwingIntent.drive,
      swipeDirection: swipeDirection,
    );
    final racketDistance = _distanceToSegment(
      point: Vector2(ball.x, ball.y),
      start: path.start,
      end: path.end,
    );
    if (racketDistance <= Tuning.committedSwingContactRadius) {
      return ContactProfile(ContactQuality.clean, _heightBand(ball));
    }
    return ContactProfile(ContactQuality.miss, _heightBand(ball));
  }

  Vector2 _committedSwingAim({
    required BallState ball,
    required PlayerState hitter,
    required SwingIntent intent,
    required Vector2 swipeDirection,
  }) {
    final forward = Vector2(0, hitter.side == PlayerSide.player ? -1 : 1);
    final swipe = swipeDirection.length2 > 0.01
        ? swipeDirection.normalized()
        : forward.clone();
    final ballVelocity = Vector2(ball.vx, ball.vy);
    final ballSpeed = ballVelocity.length;
    final ballInfluence =
        ballSpeed > 0.01 ? ballVelocity.normalized() * 0.16 : Vector2.zero();
    final playerInfluence = hitter.velocity.length2 > 1
        ? hitter.velocity.normalized() * 0.12
        : Vector2.zero();
    final relativeBall = Vector2(ball.x, ball.y) - hitter.position;
    final positionInfluence = relativeBall.length2 > 1
        ? relativeBall.normalized() * 0.14
        : Vector2.zero();

    final base = switch (intent) {
      SwingIntent.drive => Vector2(swipe.x * 0.72, forward.y * 0.74),
      SwingIntent.lob => Vector2(swipe.x * 0.30, forward.y * 1.0),
      SwingIntent.smash => Vector2(swipe.x * 0.18, forward.y * 1.12),
      SwingIntent.dink => forward.clone(),
    };
    final aim = base + ballInfluence + playerInfluence + positionInfluence;
    if (aim.length2 < 0.01) {
      return forward;
    }
    return _sideCorrectedAim(aim, hitter.side);
  }

  static SwingPath committedSwingPath({
    required PlayerState hitter,
    required SwingIntent intent,
    required Vector2 swipeDirection,
  }) {
    final forward = Vector2(0, hitter.side == PlayerSide.player ? -1 : 1);
    final lateral = Vector2(1, 0);
    final swipe = swipeDirection.length2 > 0.01
        ? swipeDirection.normalized()
        : forward.clone();
    if (intent == SwingIntent.drive) {
      final center =
          hitter.position + forward * Tuning.committedSwingForwardOffset;
      final startSign = swipe.x >= 0 ? -1.0 : 1.0;
      final start = center +
          lateral * (Tuning.committedSwingHorizontalHalfLength * startSign);
      final end = center -
          lateral * (Tuning.committedSwingHorizontalHalfLength * startSign);
      return SwingPath(start, end);
    }

    final lateralOffset = (swipe.x * 16).clamp(-18.0, 18.0).toDouble();
    final start = hitter.position +
        lateral * lateralOffset +
        forward * Tuning.committedSwingVerticalStart;
    final end = hitter.position +
        lateral * lateralOffset +
        forward * Tuning.committedSwingVerticalLength;
    return intent == SwingIntent.smash
        ? SwingPath(end, start)
        : SwingPath(start, end);
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
    final lateralScale = switch (quality) {
      ContactQuality.clean => 1.0,
      ContactQuality.forgiven => 0.62,
      ContactQuality.emergency => 0.32,
      ContactQuality.miss => 0.0,
    };
    final jitter = quality == ContactQuality.clean
        ? (_random.nextDouble() * 2 - 1) * 3
        : 0.0;
    final x = (Court.width / 2 +
            aim.x * Tuning.aimLateralReach * lateralScale +
            jitter)
        .clamp(Court.left + 12, Court.right - 12)
        .toDouble();
    final aimDepth = (-aim.y * side.sign).clamp(0.0, 1.0).toDouble();
    // Power scales how far into the shot's depth band the ball reaches. A soft
    // dink lands shallow even if aimed forward; a hard drive reaches the
    // baseline. Aim still chooses the direction.
    final depth = (aimDepth * (0.6 + power * 0.4)).clamp(0.0, 1.0).toDouble();

    final isPlayer = side == PlayerSide.player;
    // Y bands are anchored to court geometry so changing court size doesn't
    // detune the targets. Sign-flipped for the two sides.
    final dirSign = isPlayer ? -1.0 : 1.0;
    final nearOverNet = Court.netY + dirSign * 4; // just past the net
    final farKitchen = isPlayer
        ? Court.opponentKitchenTopY + 6
        : Court.playerKitchenBottomY - 6;
    final midDeep = Court.netY + dirSign * 130.0;
    final baseline = isPlayer ? Court.top + 30 : Court.bottom - 30;

    final y = switch (shotType) {
      ShotType.dink || ShotType.block => _lerp(nearOverNet, farKitchen, depth),
      ShotType.drive || ShotType.serve => _lerp(farKitchen, baseline, depth),
      // Lob lands behind the kitchen line but not at the baseline — "high
      // but not far" — so the natural arc reaches the net at clearing height.
      ShotType.lob => _lerp(farKitchen, midDeep, depth),
      ShotType.smash =>
        _lerp(nearOverNet, farKitchen, math.min(depth, 0.6) / 0.6 * 0.7),
    };
    return Vector2(x, y);
  }

  double _powerFromSwing(double swingSpeed) {
    if (swingSpeed <= Tuning.minRacketContactSpeed) {
      return 0;
    }
    return ((swingSpeed - Tuning.minRacketContactSpeed) /
            (Tuning.firmContactSpeed - Tuning.minRacketContactSpeed))
        .clamp(0.0, 1.0)
        .toDouble();
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
    final rawTime = math.max(delta.length / speed, Tuning.minShotFlightTime);
    final time = switch (shotType) {
      ShotType.dink || ShotType.block => math.min(rawTime, 1.02),
      ShotType.lob => math.min(rawTime, 1.26),
      ShotType.smash => math.min(rawTime, 0.70),
      ShotType.drive || ShotType.serve => math.min(rawTime, 1.00),
    };
    final gravity = Tuning.gravity * gravityScale;
    final solvedVz = (0 - ball.z + 0.5 * gravity * time * time) / time;
    final naturalVz = math.max(minVz, solvedVz);
    final requiredClearanceVz = _minimumVzForNetClearance(
      start: start,
      target: target,
      startZ: ball.z,
      time: time,
      gravity: gravity,
    );

    ball.vx = delta.x / time;
    ball.vy = delta.y / time;
    ball.vz = _resolveLaunchVz(
      shotType: shotType,
      naturalVz: naturalVz,
      requiredClearanceVz: requiredClearanceVz,
    );
    ball.arcGravityScale = gravityScale;
    ball.lastHitBy = hitterSide;
    ball.hasBouncedThisSide = false;
    ball.isInPlay = true;
  }

  double _resolveLaunchVz({
    required ShotType shotType,
    required double naturalVz,
    required double requiredClearanceVz,
  }) {
    if (requiredClearanceVz <= 0) {
      // Shot does not cross the net plane (e.g. wide target outside posts, or
      // same-side mishit); skip clearance logic.
      return naturalVz;
    }
    if (shotType == ShotType.serve) {
      // Serves always clear — deterministic launch experience.
      return math.max(naturalVz, requiredClearanceVz);
    }
    if (shotType == ShotType.lob || shotType == ShotType.smash) {
      // Lobs naturally arc high; smashes start above the net. No assist.
      return naturalVz;
    }
    final shortfall = requiredClearanceVz - naturalVz;
    if (shortfall <= 0) {
      return naturalVz;
    }
    // Boost the launch by up to skillForgivenessMargin. If the shortfall
    // exceeds that, the boost only partially closes it — the ball still hits
    // the net. That preserves the skill check while letting tuned shots clear.
    return naturalVz + math.min(shortfall, Tuning.skillForgivenessMargin);
  }

  double _minimumVzForNetClearance({
    required Vector2 start,
    required Vector2 target,
    required double startZ,
    required double time,
    required double gravity,
  }) {
    final deltaY = target.y - start.y;
    if (deltaY.abs() < 0.001) {
      return 0;
    }

    final crossingT = (Court.netY - start.y) / deltaY;
    if (crossingT <= 0 || crossingT >= 1) {
      return 0;
    }

    final crossingX = start.x + (target.x - start.x) * crossingT;
    if (crossingX < Court.left || crossingX > Court.right) {
      return 0;
    }

    final timeAtNet = time * crossingT;
    final clearance =
        Court.netHeight + Tuning.ballRadiusBase + Tuning.shotNetClearanceMargin;
    return (clearance - startZ + 0.5 * gravity * timeAtNet * timeAtNet) /
        timeAtNet;
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

  bool _isHittable(
    BallState ball,
    PlayerState hitter,
    ShotType shotType,
    Vector2? aim,
  ) {
    if (_isOwnLiveBallBeforeBounce(ball, hitter)) {
      return false;
    }
    if (shotType == ShotType.dink) {
      return _dinkBodyContactProfile(ball: ball, hitter: hitter).didHit;
    }
    final contact = _contactProfile(
      ball: ball,
      hitter: hitter,
      racketPosition: _racketPositionFor(ball, hitter, aim),
    );
    return contact.didHit;
  }

  bool _isOwnLiveBallBeforeBounce(BallState ball, PlayerState hitter) {
    return ball.isInPlay &&
        ball.lastHitBy == hitter.side &&
        !ball.hasBouncedThisSide;
  }

  Vector2 _racketPositionFor(BallState ball, PlayerState hitter, Vector2? aim) {
    // The racket sits between the hitter and where the ball actually is, so
    // hittability matches what the player/AI is reaching for — independent of
    // the strategic aim direction used for shot targeting.
    final toBall = Vector2(ball.x, ball.y) - hitter.position;
    final defaultY = hitter.side == PlayerSide.player ? -1.0 : 1.0;
    final reachDir = toBall.length2 > 0.01
        ? toBall.normalized()
        : (aim != null && aim.length2 > 0.01
            ? aim.normalized()
            : Vector2(0, defaultY));
    return hitter.position + reachDir * Tuning.racketReach;
  }

  Vector2 _aimDirectionFor(BallState ball, PlayerState hitter, Vector2? aim) {
    final defaultY = hitter.side == PlayerSide.player ? -1.0 : 1.0;
    if (aim != null && aim.length2 > 0.01) {
      return aim.normalized();
    }
    return Vector2(0, defaultY);
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
