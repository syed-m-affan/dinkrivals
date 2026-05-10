import 'player_side.dart';

class BallState {
  BallState({
    required this.x,
    required this.y,
    required this.z,
    this.vx = 0,
    this.vy = 0,
    this.vz = 0,
    this.lastHitBy,
    this.hasBouncedThisSide = false,
    this.isInPlay = false,
    this.arcGravityScale = 1,
  });

  double x;
  double y;
  double z;
  double vx;
  double vy;
  double vz;
  PlayerSide? lastHitBy;
  bool hasBouncedThisSide;
  bool isInPlay;
  double arcGravityScale;

  PlayerSide get currentSide {
    return y >= 240 ? PlayerSide.player : PlayerSide.opponent;
  }
}
