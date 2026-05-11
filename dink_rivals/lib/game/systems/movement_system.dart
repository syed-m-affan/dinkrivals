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
      player.velocity.setFrom(desired);
    } else {
      final drop = Tuning.playerAcceleration * dt;
      if (player.velocity.length <= drop) {
        player.velocity.setZero();
      } else {
        final friction = player.velocity.normalized()..scale(drop);
        player.velocity.sub(friction);
      }
    }

    player.position.add(player.velocity * dt);
    player.position.x =
        player.position.x.clamp(Court.left, Court.right).toDouble();
    player.position.y =
        player.position.y.clamp(Court.netY, Court.bottom).toDouble();
  }
}
