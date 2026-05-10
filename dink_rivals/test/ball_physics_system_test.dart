import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/models/ball_state.dart';
import 'package:dink_rivals/game/systems/ball_physics_system.dart';

void main() {
  test('ball with positive vz rises then falls', () {
    final ball = BallState(x: 110, y: 300, z: 10, vz: 180, isInPlay: true);
    final physics = BallPhysicsSystem();

    physics.update(ball, 0.1);
    final afterRise = ball.z;

    for (var i = 0; i < 12; i++) {
      physics.update(ball, 0.1);
    }

    expect(afterRise, greaterThan(10));
    expect(ball.z, lessThan(afterRise));
  });

  test('ball bounces with reduced velocity when z hits ground', () {
    final ball = BallState(x: 110, y: 300, z: 1, vz: -100, isInPlay: true);
    final physics = BallPhysicsSystem();

    physics.update(ball, 0.05);

    expect(ball.z, 0);
    expect(ball.vz, greaterThan(0));
    expect(ball.vz, lessThan(100));
    expect(ball.hasBouncedThisSide, isTrue);
  });

  test('ball comes to rest after multiple bounces', () {
    final ball = BallState(x: 110, y: 300, z: 0, vz: 140, isInPlay: true);
    final physics = BallPhysicsSystem();

    for (var i = 0; i < 500; i++) {
      physics.update(ball, 0.05);
    }

    expect(ball.z, 0);
    expect(ball.vz, 0);
    expect(ball.isInPlay, isFalse);
  });

  test('ball position updates across one second of integration', () {
    final ball = BallState(x: 50, y: 100, z: 50, vx: 20, vy: 40, vz: 0, isInPlay: true);
    final physics = BallPhysicsSystem();

    physics.update(ball, 1);

    expect(ball.x, closeTo(69.4, 0.001));
    expect(ball.y, closeTo(138.8, 0.001));
    expect(ball.z, 0);
  });

  test('ball rebounds from court boundary instead of sticking', () {
    final ball = BallState(
      x: Court.right - 1,
      y: 300,
      z: 30,
      vx: 80,
      isInPlay: true,
    );
    final physics = BallPhysicsSystem();

    physics.update(ball, 0.1);

    expect(ball.x, Court.right);
    expect(ball.vx, lessThan(0));
  });

  test('ball does not move while point is reset', () {
    final ball = BallState(
      x: 110,
      y: 440,
      z: 0,
      vx: 100,
      vy: -100,
      vz: 80,
      isInPlay: false,
    );
    final physics = BallPhysicsSystem();

    physics.update(ball, 1);

    expect(ball.x, 110);
    expect(ball.y, 440);
    expect(ball.z, 0);
    expect(ball.vx, 100);
    expect(ball.vy, -100);
    expect(ball.vz, 80);
  });
}
