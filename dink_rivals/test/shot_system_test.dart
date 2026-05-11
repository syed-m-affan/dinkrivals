import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/config/tuning_constants.dart';
import 'package:dink_rivals/game/models/ball_state.dart';
import 'package:dink_rivals/game/models/player_side.dart';
import 'package:dink_rivals/game/models/player_state.dart';
import 'package:dink_rivals/game/models/shot_type.dart';
import 'package:dink_rivals/game/models/swing_intent.dart';
import 'package:dink_rivals/game/systems/shot_system.dart';

void main() {
  test('first hit cannot use player body instead of racket', () {
    final ball = BallState(
      x: Court.playerStartX,
      y: Court.playerStartY,
      z: 0,
      isInPlay: false,
    );
    final player = PlayerState(
      position: Vector2(Court.playerStartX, Court.playerStartY),
      side: PlayerSide.player,
    );

    final didHit = ShotSystem().attemptShot(
      ball: ball,
      hitter: player,
      opponent: PlayerState(
        position: Vector2(Court.opponentStartX, Court.opponentStartY),
        side: PlayerSide.opponent,
      ),
      shotType: ShotType.dink,
    );

    expect(didHit, isFalse);
    expect(ball.isInPlay, isFalse);
  });

  test('first hit uses racket contact hitbox', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketDirection = Vector2(0, -1);
    final racketPosition =
        player.position + racketDirection * Tuning.racketReach;
    final ball = BallState(
      x: racketPosition.x,
      y: racketPosition.y,
      z: 0,
      isInPlay: false,
    );

    final didHit = ShotSystem().attemptRacketContact(
      ball: ball,
      hitter: player,
      racketPosition: racketPosition,
      racketDirection: racketDirection,
      racketVelocity: Vector2(90, 0),
    );

    expect(didHit, isTrue);
    expect(ball.isInPlay, isTrue);
    expect(ball.lastHitBy, PlayerSide.player);
    expect(ball.vy, lessThan(0));
    expect(ball.vz, greaterThan(0));
  });

  test('soft serve swing still lifts ball into play', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketDirection = Vector2(0, -1);
    final racketPosition =
        player.position + racketDirection * Tuning.racketReach;
    final ball = BallState(
      x: racketPosition.x,
      y: racketPosition.y,
      z: 0,
      isInPlay: false,
    );

    final didHit = ShotSystem().attemptRacketContact(
      ball: ball,
      hitter: player,
      racketPosition: racketPosition,
      racketDirection: racketDirection,
      racketVelocity: Vector2(Tuning.minRacketContactSpeed + 1, 0),
    );

    expect(didHit, isTrue);
    expect(ball.isInPlay, isTrue);
    expect(ball.vy, lessThan(0));
    expect(ball.vz, greaterThanOrEqualTo(Tuning.contactLiftBase));
  });

  test('racket shaft between player and tip is hittable', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketDirection = Vector2(0, -1);
    final racketPosition =
        player.position + racketDirection * Tuning.racketReach;
    final ball = BallState(
      x: player.position.x,
      y: player.position.y - Tuning.racketReach * 0.5,
      z: 20,
      isInPlay: true,
    );

    final didHit = ShotSystem().attemptRacketContact(
      ball: ball,
      hitter: player,
      racketPosition: racketPosition,
      racketDirection: racketDirection,
      racketVelocity: Vector2(90, 0),
    );

    expect(didHit, isTrue);
    expect(ball.lastHitBy, PlayerSide.player);
  });

  test('faster racket swing produces faster outgoing ball', () {
    final slow = _hitWithSwingSpeed(45);
    final fast = _hitWithSwingSpeed(180);

    expect(Vector2(fast.vx, fast.vy).length,
        greaterThan(Vector2(slow.vx, slow.vy).length));
  });

  test('racket angle changes outgoing x direction', () {
    final left = _hitWithDirection(Vector2(-0.8, -1)..normalize());
    final right = _hitWithDirection(Vector2(0.8, -1)..normalize());

    expect(left.vx, lessThan(0));
    expect(right.vx, greaterThan(0));
  });

  test('open soft racket contact classifies as lob with higher lift', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketDirection = Vector2(0.9, -0.4)..normalize();
    final racketPosition =
        player.position + racketDirection * Tuning.racketReach;
    final ball = BallState(
      x: racketPosition.x,
      y: racketPosition.y,
      z: 30,
      vy: 30,
      isInPlay: true,
    );

    ShotSystem().attemptRacketContact(
      ball: ball,
      hitter: player,
      racketPosition: racketPosition,
      racketDirection: racketDirection,
      racketVelocity: Vector2(35, 0),
    );

    expect(ball.vz, greaterThanOrEqualTo(Tuning.lobInitialZ));
  });

  test('smash requires ball height threshold', () {
    final highShotSystem = ShotSystem();
    final lowShotSystem = ShotSystem();
    final high = _hitHighBall(
        z: Tuning.smashMinBallHeight + 5, shotSystem: highShotSystem);
    _hitHighBall(z: Tuning.smashMinBallHeight - 5, shotSystem: lowShotSystem);

    expect(highShotSystem.lastShotType, ShotType.smash);
    expect(high.vz, greaterThan(0));
    expect(lowShotSystem.lastShotType, isNot(ShotType.smash));
  });

  test(
      'stationary ball swung left-to-right with forward face goes forward-right',
      () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketDirection = Vector2(0, -1);
    final racketPosition =
        player.position + racketDirection * Tuning.racketReach;
    final ball = BallState(
      x: racketPosition.x,
      y: racketPosition.y,
      z: 0,
      isInPlay: false,
    );

    ShotSystem().attemptRacketContact(
      ball: ball,
      hitter: player,
      racketPosition: racketPosition,
      racketDirection: racketDirection,
      racketVelocity: Vector2(90, 0),
    );

    expect(ball.vx, greaterThan(0));
    expect(ball.vy, lessThan(0));
    expect(ball.vx, greaterThan(-ball.vy * 0.3));
  });

  test('incoming ball reflects off angled face', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketDirection = Vector2(0.5, -0.866);
    final racketPosition =
        player.position + racketDirection * Tuning.racketReach;
    final ball = BallState(
      x: racketPosition.x,
      y: racketPosition.y,
      z: 30,
      vy: 30,
      isInPlay: true,
    );

    ShotSystem().attemptRacketContact(
      ball: ball,
      hitter: player,
      racketPosition: racketPosition,
      racketDirection: racketDirection,
      racketVelocity: Vector2.zero(),
    );

    expect(ball.vx, greaterThan(0));
    expect(ball.vy, lessThan(0));
  });

  test('ball above playable height is not hittable', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketDirection = Vector2(0, -1);
    final racketPosition =
        player.position + racketDirection * Tuning.racketReach;
    final ball = BallState(
      x: racketPosition.x,
      y: racketPosition.y,
      z: Tuning.playableBallMaxZ + 2,
      isInPlay: true,
    );

    final didHit = ShotSystem().attemptRacketContact(
      ball: ball,
      hitter: player,
      racketPosition: racketPosition,
      racketDirection: racketDirection,
      racketVelocity: Vector2(90, 0),
    );

    expect(didHit, isFalse);
  });

  test('ball below vertical capsule bottom is not hittable', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketDirection = Vector2(0, -1);
    final racketPosition =
        player.position + racketDirection * Tuning.racketReach;
    final belowZ = Tuning.racketContactZ - Tuning.verticalHitRadius - 2;
    final ball = BallState(
      x: racketPosition.x,
      y: racketPosition.y,
      z: belowZ < 0 ? -1 : belowZ,
      isInPlay: true,
    );

    final didHit = ShotSystem().attemptRacketContact(
      ball: ball,
      hitter: player,
      racketPosition: racketPosition,
      racketDirection: racketDirection,
      racketVelocity: Vector2(90, 0),
    );

    expect(didHit, isFalse);
  });

  test('ball past fuzzy contact radius is not hittable', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketDirection = Vector2(0, -1);
    final racketPosition =
        player.position + racketDirection * Tuning.racketReach;
    final ball = BallState(
      x: racketPosition.x + Tuning.forgivenContactRadius + 2,
      y: racketPosition.y,
      z: Tuning.racketContactZ,
      isInPlay: true,
    );

    final didHit = ShotSystem().attemptRacketContact(
      ball: ball,
      hitter: player,
      racketPosition: racketPosition,
      racketDirection: racketDirection,
      racketVelocity: Vector2(90, 0),
    );

    expect(didHit, isFalse);
  });

  test('smash threshold remains within vertical capsule', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketDirection = Vector2(0, -1);
    final racketPosition =
        player.position + racketDirection * Tuning.racketReach;
    final ball = BallState(
      x: racketPosition.x,
      y: racketPosition.y,
      z: Tuning.smashMinBallHeight + 1,
      vy: 80,
      isInPlay: true,
    );
    final shotSystem = ShotSystem();

    final didHit = shotSystem.attemptRacketContact(
      ball: ball,
      hitter: player,
      racketPosition: racketPosition,
      racketDirection: racketDirection,
      racketVelocity: Vector2(180, 0),
    );

    expect(didHit, isTrue);
    expect(shotSystem.lastShotType, ShotType.smash);
  });

  test('manual passive contact converts to a low-power dink', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketPosition = player.position + Vector2(0, -Tuning.racketReach);
    final ball = BallState(
      x: racketPosition.x,
      y: racketPosition.y,
      z: Tuning.lowBallMaxZ,
      vy: 40,
      isInPlay: true,
    );
    final shotSystem = ShotSystem();

    final didHit = shotSystem.attemptManualContact(
      ball: ball,
      hitter: player,
      racketPosition: racketPosition,
      aimDirection: Vector2(0, -1),
    );

    expect(didHit, isTrue);
    expect(shotSystem.lastShotType, ShotType.dink);
    expect(ball.vy, lessThan(0));
  });

  test('manual smash intent misses below smashable ball height', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketPosition = player.position + Vector2(0, -Tuning.racketReach);
    final lowBall = BallState(
      x: racketPosition.x,
      y: racketPosition.y,
      z: Tuning.lowBallMaxZ,
      vy: 40,
      isInPlay: true,
    );
    final highBall = BallState(
      x: racketPosition.x,
      y: racketPosition.y,
      z: Tuning.smashableBallMinZ + 4,
      vy: 40,
      isInPlay: true,
    );
    final lowShotSystem = ShotSystem();
    final highShotSystem = ShotSystem();

    final lowHit = lowShotSystem.attemptManualContact(
      ball: lowBall,
      hitter: player,
      racketPosition: racketPosition,
      aimDirection: Vector2(0, -1),
      intent: SwingIntent.smash,
      power: 1,
    );
    highShotSystem.attemptManualContact(
      ball: highBall,
      hitter: player,
      racketPosition: racketPosition,
      aimDirection: Vector2(0, -1),
      intent: SwingIntent.smash,
      power: 1,
    );

    expect(lowHit, isFalse);
    expect(lowShotSystem.lastShotType, isNull);
    expect(highShotSystem.lastShotType, ShotType.smash);
  });

  test('committed swing outside strict hitbox misses instead of dinking', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketPosition = player.position + Vector2(0, -Tuning.racketReach);
    final swingBall = BallState(
      x: racketPosition.x + Tuning.committedSwingContactRadius + 4,
      y: racketPosition.y,
      z: Tuning.racketContactZ,
      vy: 40,
      isInPlay: true,
      lastHitBy: PlayerSide.opponent,
    );
    final shotSystem = ShotSystem();

    final didHit = shotSystem.attemptManualContact(
      ball: swingBall,
      hitter: player,
      racketPosition: racketPosition,
      aimDirection: Vector2(0.4, -1),
      intent: SwingIntent.drive,
      power: 0.8,
    );

    expect(didHit, isFalse);
    expect(shotSystem.lastShotType, isNull);
    expect(swingBall.vy, 40);
  });

  test('passive contact can still dink inside forgiving hitbox', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketPosition = player.position + Vector2(0, -Tuning.racketReach);
    final ball = BallState(
      x: racketPosition.x + Tuning.committedSwingContactRadius + 4,
      y: racketPosition.y,
      z: Tuning.racketContactZ,
      vy: 40,
      isInPlay: true,
      lastHitBy: PlayerSide.opponent,
    );
    final shotSystem = ShotSystem();

    final didHit = shotSystem.attemptManualContact(
      ball: ball,
      hitter: player,
      racketPosition: racketPosition,
      aimDirection: Vector2(0.4, -1),
    );

    expect(didHit, isTrue);
    expect(shotSystem.lastShotType, ShotType.dink);
    expect(ball.vy, lessThan(0));
  });

  test('serve launches ball forward at minimum serve speed and lift', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketDirection = Vector2(0, -1);
    final ball = BallState(
      x: 110,
      y: 400 - Tuning.racketReach,
      z: 0,
      isInPlay: false,
    );

    ShotSystem().serve(
      ball: ball,
      hitter: player,
      racketDirection: racketDirection,
    );

    expect(ball.isInPlay, isTrue);
    expect(ball.lastHitBy, PlayerSide.player);
    expect(ball.vy, closeTo(-Tuning.serveMinOutputSpeed, 0.01));
    expect(ball.vz, Tuning.serveMinLift);
  });

  test('serve aims along racket direction', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final racketDirection = Vector2(0.6, -0.8);
    final ball = BallState(x: 110, y: 360, z: 0, isInPlay: false);

    ShotSystem().serve(
      ball: ball,
      hitter: player,
      racketDirection: racketDirection,
    );

    expect(ball.vx, greaterThan(0));
    expect(ball.vy, lessThan(0));
  });

  test('charged serve is faster and higher than minimum serve', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final weakServe = BallState(x: 110, y: 360, z: 0, isInPlay: false);
    final chargedServe = BallState(x: 110, y: 360, z: 0, isInPlay: false);

    ShotSystem().serve(
      ball: weakServe,
      hitter: player,
      racketDirection: Vector2(0, -1),
      power: 0,
    );
    ShotSystem().serve(
      ball: chargedServe,
      hitter: player,
      racketDirection: Vector2(0, -1),
      power: 1,
    );

    expect(chargedServe.vy.abs(), greaterThan(weakServe.vy.abs()));
    expect(chargedServe.vz, greaterThan(weakServe.vz));
    expect(chargedServe.vy, closeTo(-Tuning.serveMaxOutputSpeed, 0.01));
    expect(chargedServe.vz, Tuning.serveMaxLift);
  });

  test('serve power clamps to valid range', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    final ball = BallState(x: 110, y: 360, z: 0, isInPlay: false);

    ShotSystem().serve(
      ball: ball,
      hitter: player,
      racketDirection: Vector2(0, -1),
      power: 4,
    );

    expect(ball.vy, closeTo(-Tuning.serveMaxOutputSpeed, 0.01));
    expect(ball.vz, Tuning.serveMaxLift);
  });

  test('running diagonally biases shot toward run direction', () {
    final player = PlayerState(
      position: Vector2(110, 400),
      side: PlayerSide.player,
    );
    player.velocity.setValues(-180, -180);
    final racketDirection = Vector2(0, -1);
    final racketPosition =
        player.position + racketDirection * Tuning.racketReach;
    final ball = BallState(
      x: racketPosition.x,
      y: racketPosition.y,
      z: 30,
      vy: 50,
      isInPlay: true,
    );

    ShotSystem().attemptRacketContact(
      ball: ball,
      hitter: player,
      racketPosition: racketPosition,
      racketDirection: racketDirection,
      racketVelocity: Vector2(0, -90),
    );

    expect(ball.vx, lessThan(0));
    expect(ball.vy, lessThan(0));
  });
}

BallState _hitWithSwingSpeed(double swingSpeed) {
  final player = PlayerState(
    position: Vector2(110, 400),
    side: PlayerSide.player,
  );
  final racketDirection = Vector2(0, -1);
  final racketPosition = player.position + racketDirection * Tuning.racketReach;
  final ball = BallState(
    x: racketPosition.x,
    y: racketPosition.y,
    z: 30,
    vy: 50,
    isInPlay: true,
  );

  ShotSystem().attemptRacketContact(
    ball: ball,
    hitter: player,
    racketPosition: racketPosition,
    racketDirection: racketDirection,
    racketVelocity: Vector2(swingSpeed, 0),
  );
  return ball;
}

BallState _hitWithDirection(Vector2 racketDirection) {
  final player = PlayerState(
    position: Vector2(110, 400),
    side: PlayerSide.player,
  );
  final racketPosition = player.position + racketDirection * Tuning.racketReach;
  final ball = BallState(
    x: racketPosition.x,
    y: racketPosition.y,
    z: 30,
    vy: 50,
    isInPlay: true,
  );

  ShotSystem().attemptRacketContact(
    ball: ball,
    hitter: player,
    racketPosition: racketPosition,
    racketDirection: racketDirection,
    racketVelocity: racketDirection.clone()..scale(120),
  );
  return ball;
}

BallState _hitHighBall({required double z, ShotSystem? shotSystem}) {
  final player = PlayerState(
    position: Vector2(110, 400),
    side: PlayerSide.player,
  );
  final racketDirection = Vector2(0, -1);
  final racketPosition = player.position + racketDirection * Tuning.racketReach;
  final ball = BallState(
    x: racketPosition.x,
    y: racketPosition.y,
    z: z,
    vy: 80,
    isInPlay: true,
  );

  (shotSystem ?? ShotSystem()).attemptRacketContact(
    ball: ball,
    hitter: player,
    racketPosition: racketPosition,
    racketDirection: racketDirection,
    racketVelocity: Vector2(180, 0),
  );
  return ball;
}
