import '../config/court_constants.dart';
import '../config/tuning_constants.dart';
import '../models/ball_state.dart';

class BallPhysicsSystem {
  BallPhysicsResult update(BallState ball, double dt) {
    if (!ball.isInPlay) {
      return const BallPhysicsResult();
    }

    final previousY = ball.y;
    final drag = 1 - Tuning.airDrag * dt;
    var groundContact = false;
    var wasDoubleBounce = false;
    var landedOutOfBounds = false;

    ball.vx *= drag;
    ball.vy *= drag;
    ball.vz -= Tuning.gravity * ball.arcGravityScale * dt;

    ball.x += ball.vx * dt;
    ball.y += ball.vy * dt;
    ball.z += ball.vz * dt;

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

    if (ball.x < Court.left) {
      ball.x = Court.left;
      ball.vx = ball.vx.abs() * 0.45;
    } else if (ball.x > Court.right) {
      ball.x = Court.right;
      ball.vx = -ball.vx.abs() * 0.45;
    }
    if (ball.y < Court.top) {
      ball.y = Court.top;
      ball.vy = ball.vy.abs() * 0.45;
    } else if (ball.y > Court.bottom) {
      ball.y = Court.bottom;
      ball.vy = -ball.vy.abs() * 0.45;
    }

    final crossedNet = (previousY - Court.netY) * (ball.y - Court.netY) < 0;
    if (crossedNet) {
      ball.hasBouncedThisSide = false;
    }
    return BallPhysicsResult(
      crossedNet: crossedNet,
      groundContact: groundContact,
      wasDoubleBounce: wasDoubleBounce,
      landedOutOfBounds: landedOutOfBounds,
    );
  }
}

class BallPhysicsResult {
  const BallPhysicsResult({
    this.crossedNet = false,
    this.groundContact = false,
    this.wasDoubleBounce = false,
    this.landedOutOfBounds = false,
  });

  final bool crossedNet;
  final bool groundContact;
  final bool wasDoubleBounce;
  final bool landedOutOfBounds;
}
