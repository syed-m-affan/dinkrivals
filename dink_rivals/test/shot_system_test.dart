import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/config/tuning_constants.dart';
import 'package:dink_rivals/game/models/ball_state.dart';
import 'package:dink_rivals/game/models/player_side.dart';
import 'package:dink_rivals/game/models/player_state.dart';
import 'package:dink_rivals/game/models/shot_type.dart';
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

    expect(ball.vz, Tuning.lobInitialZ);
  });

  test('smash requires ball height threshold', () {
    final high = _hitHighBall(z: Tuning.smashMinBallHeight + 5);
    final low = _hitHighBall(z: Tuning.smashMinBallHeight - 5);

    expect(high.vz, Tuning.smashInitialZ);
    expect(low.vz, isNot(Tuning.smashInitialZ));
  });

  test('stationary ball swung left-to-right with forward face goes forward-right', () {
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

BallState _hitHighBall({required double z}) {
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

  ShotSystem().attemptRacketContact(
    ball: ball,
    hitter: player,
    racketPosition: racketPosition,
    racketDirection: racketDirection,
    racketVelocity: Vector2(180, 0),
  );
  return ball;
}
