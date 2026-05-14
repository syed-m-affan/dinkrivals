import '../config/court_constants.dart';
import '../config/tuning_constants.dart';
import '../models/ball_state.dart';

class BallPhysicsSystem {
  BallPhysicsResult update(BallState ball, double dt) {
    if (!ball.isInPlay) {
      return const BallPhysicsResult();
    }

    final previousX = ball.x;
    final previousY = ball.y;
    final previousZ = ball.z;
    final drag = 1 - Tuning.airDrag * dt;
    var groundContact = false;
    var wasDoubleBounce = false;
    var landedOutOfBounds = false;
    var netContact = false;

    ball.vx *= drag;
    ball.vy *= drag;
    ball.vz -= Tuning.gravity * ball.arcGravityScale * dt;

    ball.x += ball.vx * dt;
    ball.y += ball.vy * dt;
    ball.z += ball.vz * dt;

    final crossedNetPlane =
        (previousY - Court.netY) * (ball.y - Court.netY) < 0;
    if (crossedNetPlane) {
      final crossingT = (Court.netY - previousY) / (ball.y - previousY);
      final netX = previousX + (ball.x - previousX) * crossingT;
      final netZ = previousZ + (ball.z - previousZ) * crossingT;
      final netClearanceHeight = Court.netHeight + Tuning.ballRadiusBase;
      netContact = netX >= Court.left &&
          netX <= Court.right &&
          netZ <= netClearanceHeight;
      if (netContact) {
        ball.x = netX;
        ball.y = Court.netY;
        ball.z = netZ.clamp(0.0, netClearanceHeight).toDouble();
        ball.vx *= 0.15;
        ball.vy = 0;
        ball.vz = ball.vz < 0 ? ball.vz * 0.35 : -Tuning.minBounceVelocity;
      }
    }

    if (ball.z <= 0) {
      groundContact = true;
      wasDoubleBounce = ball.hasBouncedThisSide;
      landedOutOfBounds = ball.x < Court.left ||
          ball.x > Court.right ||
          ball.y < Court.top ||
          ball.y > Court.bottom;
      ball.z = 0;
      if (ball.vz < 0) {
        ball.vz = -ball.vz * Tuning.bounceDamping;
        if (ball.vz < Tuning.minBounceVelocity) {
          ball.vz = 0;
          ball.vx = 0;
          ball.vy = 0;
          ball.isInPlay = false;
        }
      }
      ball.hasBouncedThisSide = true;
    }

    // Soft boundary rebound removed: live balls must be allowed to land out
    // of bounds so MatchRulesSystem can resolve the OOB fault. Resting balls
    // (`isInPlay == false`) are short-circuited at the top of update and
    // repositioned by `DinkRivalsGame.resetPoint()` instead. See P1-008.

    final crossedNet = crossedNetPlane && !netContact;
    if (crossedNet) {
      ball.hasBouncedThisSide = false;
    }
    return BallPhysicsResult(
      crossedNet: crossedNet,
      netContact: netContact,
      groundContact: groundContact,
      wasDoubleBounce: wasDoubleBounce,
      landedOutOfBounds: landedOutOfBounds,
    );
  }
}

class BallPhysicsResult {
  const BallPhysicsResult({
    this.crossedNet = false,
    this.netContact = false,
    this.groundContact = false,
    this.wasDoubleBounce = false,
    this.landedOutOfBounds = false,
  });

  final bool crossedNet;
  final bool netContact;
  final bool groundContact;
  final bool wasDoubleBounce;
  final bool landedOutOfBounds;
}
