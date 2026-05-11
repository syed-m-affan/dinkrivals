class Tuning {
  static const int quickMatchWinningScore = 7;

  static const double playerMaxSpeed = 240.0;
  static const double playerAcceleration = 1350.0;
  static const double opponentMaxSpeed = 84.0;

  static const double hitWindowRadius = 50.0;
  static const double perfectHitWindowRadius = 22.0;
  static const double racketReach = 42.0;
  static const double racketHitRadius = 10.0;
  // Canonical racket-plane altitude used by both the visual draw and the
  // hitbox capsule. Matches the player torso line (z=0→16) so the racket
  // visually emerges from where the player would hold it.
  static const double racketContactZ = 16.0;
  // Vertical half-extent of the hitbox capsule around `racketContactZ`. Must
  // stay >= (smashMinBallHeight - racketContactZ) so smash-height balls
  // remain hittable.
  static const double verticalHitRadius = 18.0;
  static const double maxRacketAngleRadians = 1.5708;
  static const double racketSwingRadiansPerPixel = 0.005;
  static const double racketHitCooldown = 0.18;
  static const double minRacketContactSpeed = 5.0;
  static const double softContactSpeed = 88.0;
  static const double firmContactSpeed = 150.0;
  static const double driveContactThreshold = 118.0;
  static const double lobAngleThreshold = 0.65;
  static const double smashMinBallHeight = 28.0;
  static const double smashContactSpeed = 132.0;
  static const double swingPowerScale = 0.50;
  static const double incomingPowerScale = 0.24;
  static const double playerPushScale = 0.7;
  static const double dirShaftWeight = 0.50;
  static const double dirSwingWeight = 0.30;
  static const double dirReflectWeight = 0.30;
  static const double dirPushWeight = 0.12;
  static const double reflectFullSpeed = 140.0;
  static const double swingDirMinSpeed = 18.0;
  static const double playerPushMinSpeed = 20.0;
  static const double backwardClampDot = -0.15;
  static const double contactLiftBase = 48.0;
  static const double contactLiftScale = 0.30;
  static const double serveMinOutputSpeed = 175.0;
  static const double serveMaxOutputSpeed = 245.0;
  static const double serveMinLift = 130.0;
  static const double serveMaxLift = 170.0;
  static const double serveChargeDuration = 1.15;
  static const double serveArcGravityScale = 0.40;
  // Dedicated opponent-serve profile. Calibrated so the ball lands roughly
  // around the player's kitchen line (court y ≈ 270-290) instead of the
  // back baseline — opponent serves should be returnable for a beginner.
  static const double opponentServeSpeed = 130.0;
  static const double opponentServeLift = 140.0;

  static const double gravity = 440.0;
  static const double bounceDamping = 0.76;
  static const double minBounceVelocity = 11.0;
  static const double airDrag = 0.03;

  static const double dinkSpeedXY = 82.0;
  static const double dinkInitialZ = 34.0;
  static const double dinkArcGravityScale = 0.92;

  static const double driveSpeedXY = 116.0;
  static const double driveInitialZ = 30.0;
  static const double driveArcGravityScale = 0.36;

  static const double lobSpeedXY = 92.0;
  static const double lobInitialZ = 130.0;
  static const double lobArcGravityScale = 0.40;

  static const double smashSpeedXY = 150.0;
  static const double smashInitialZ = 10.0;
  static const double smashArcGravityScale = 1.15;

  static const double opponentReactionDelaySec = 0.40;
  static const double opponentWhiffChance = 0.30;
  static const double opponentDinkProbability = 0.66;
  static const double opponentLobProbability = 0.32;
  static const double opponentSmashProbability = 0.28;
  static const double opponentSmashMinBallHeight = 30.0;
  static const double opponentTargetJitter = 36.0;
}
