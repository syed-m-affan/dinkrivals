import 'package:flame/components.dart';

import 'player_side.dart';
import 'shot_type.dart';

class PlayerState {
  PlayerState({
    required this.position,
    required this.side,
    Vector2? velocity,
    this.canHit = true,
    this.isSwinging = false,
  }) : velocity = velocity ?? Vector2.zero();

  Vector2 position;
  Vector2 velocity;
  PlayerSide side;
  bool canHit;
  bool isSwinging;
  ShotType? lastShotType;
}
