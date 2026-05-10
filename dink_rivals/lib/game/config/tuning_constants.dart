class Tuning {
  static const int quickMatchWinningScore = 7;

  static const double playerMaxSpeed = 240.0;
  static const double playerAcceleration = 1350.0;
  static const double opponentMaxSpeed = 74.0;

  static const double hitWindowRadius = 50.0;
  static const double perfectHitWindowRadius = 22.0;
  static const double racketReach = 42.0;
  static const double racketHitRadius = 13.0;
  static const double maxRacketAngleRadians = 1.5708;
  static const double racketSwingRadiansPerPixel = 0.016;
  static const double racketHitCooldown = 0.18;
  static const double minRacketContactSpeed = 5.0;
  static const double softContactSpeed = 88.0;
  static const double firmContactSpeed = 176.0;
  static const double driveContactThreshold = 124.0;
  static const double lobAngleThreshold = 0.86;
  static const double smashMinBallHeight = 64.0;
  static const double smashContactSpeed = 132.0;
  static const double swingPowerScale = 0.62;
  static const double incomingPowerScale = 0.24;
  static const double playerPushScale = 0.7;
  static const double racketFaceWeight = 0.88;
  static const double contactLiftBase = 48.0;
  static const double contactLiftScale = 0.30;
  static const double serveMinOutputSpeed = 150.0;
  static const double serveMinLift = 82.0;

  static const double gravity = 440.0;
  static const double bounceDamping = 0.76;
  static const double minBounceVelocity = 11.0;
  static const double airDrag = 0.03;

  static const double dinkSpeedXY = 82.0;
  static const double dinkInitialZ = 34.0;
  static const double dinkArcGravityScale = 0.75;

  static const double driveSpeedXY = 132.0;
  static const double driveInitialZ = 30.0;
  static const double driveArcGravityScale = 0.42;

  static const double lobSpeedXY = 92.0;
  static const double lobInitialZ = 86.0;
  static const double lobArcGravityScale = 0.54;

  static const double smashSpeedXY = 170.0;
  static const double smashInitialZ = 10.0;
  static const double smashArcGravityScale = 1.15;

  static const double opponentReactionDelaySec = 0.44;
  static const double opponentMissChance = 0.22;
  static const double opponentDinkProbability = 0.55;
}
