import 'dart:math' as math;

import 'package:flame/components.dart';

import '../config/court_constants.dart';
import '../config/tuning_constants.dart';
import '../models/player_state.dart';

class MovementSystem {
  void update({
    required PlayerState player,
    required double inputX,
    required double inputY,
    required bool hasInput,
    required double dt,
  }) {
    if (hasInput) {
      final desired = Vector2(inputX, inputY);
      if (desired.length2 > 1) {
        desired.normalize();
      }
      desired.scale(Tuning.playerMaxSpeed);
      _moveVelocityToward(player.velocity, desired, Tuning.playerAcceleration * dt);
    } else {
      final drop = Tuning.playerMaxSpeed * 5 * dt;
      if (player.velocity.length <= drop) {
        player.velocity.setZero();
      } else {
        final friction = player.velocity.normalized()..scale(drop);
        player.velocity.sub(friction);
      }
    }

    player.position.add(player.velocity * dt);
    player.position.x = player.position.x.clamp(Court.left, Court.right).toDouble();
    player.position.y = player.position.y.clamp(Court.netY, Court.bottom).toDouble();
  }

  void _moveVelocityToward(Vector2 velocity, Vector2 desired, double maxDelta) {
    final delta = desired - velocity;
    final distance = delta.length;
    if (distance <= maxDelta || distance == 0) {
      velocity.setFrom(desired);
      return;
    }
    velocity.add(delta..scale(maxDelta / math.max(distance, 0.0001)));
  }
}
