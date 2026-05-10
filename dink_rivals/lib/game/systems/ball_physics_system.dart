import '../config/court_constants.dart';
import '../config/tuning_constants.dart';
import '../models/ball_state.dart';

class BallPhysicsSystem {
  PlayerSideCrossing? update(BallState ball, double dt) {
    final previousY = ball.y;
    final drag = 1 - Tuning.airDrag * dt;

    ball.vx *= drag;
    ball.vy *= drag;
    ball.vz -= Tuning.gravity * ball.arcGravityScale * dt;

    ball.x += ball.vx * dt;
    ball.y += ball.vy * dt;
    ball.z += ball.vz * dt;

    if (ball.z <= 0) {
      ball.z = 0;
      if (ball.vz < 0) {
        ball.vz = -ball.vz * Tuning.bounceDamping;
        if (ball.vz < 10) {
          ball.vz = 0;
          ball.vx = 0;
          ball.vy = 0;
          ball.isInPlay = false;
        }
      }
      ball.hasBouncedThisSide = true;
    }

    ball.x = ball.x.clamp(Court.left, Court.right).toDouble();
    ball.y = ball.y.clamp(Court.top, Court.bottom).toDouble();

    if ((previousY - Court.netY) * (ball.y - Court.netY) < 0) {
      ball.hasBouncedThisSide = false;
      return PlayerSideCrossing();
    }
    return null;
  }
}

class PlayerSideCrossing {}
