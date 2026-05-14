import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/models/ball_state.dart';
import 'package:dink_rivals/game/models/match_state.dart';
import 'package:dink_rivals/game/models/player_side.dart';
import 'package:dink_rivals/game/models/player_state.dart';
import 'package:dink_rivals/game/models/rule_result.dart';
import 'package:dink_rivals/game/systems/ball_physics_system.dart';
import 'package:dink_rivals/game/systems/match_rules_system.dart';

void main() {
  test('in-bounds first ground contact continues play', () {
    final rules = MatchRulesSystem();
    final ball = BallState(x: 110, y: 300, z: 0);

    final result = rules.evaluateGroundContact(ball);

    expect(result.pointEnded, isFalse);
  });

  test('out-of-bounds landing awards point to other side', () {
    final rules = MatchRulesSystem();
    final ball = BallState(
      x: Court.right + 1,
      y: 120,
      z: 0,
      lastHitBy: PlayerSide.player,
    );

    final result = rules.evaluateGroundContact(ball);

    expect(result.pointEnded, isTrue);
    expect(result.winner, PlayerSide.opponent);
    expect(result.fault, RuleFault.outOfBounds);
  });

  test('double bounce awards point to other side', () {
    final rules = MatchRulesSystem();
    final ball = BallState(
      x: 110,
      y: 300,
      z: 0,
      hasBouncedThisSide: true,
    );

    final result = rules.evaluateGroundContact(ball);

    expect(result.pointEnded, isTrue);
    expect(result.winner, PlayerSide.opponent);
    expect(result.fault, RuleFault.doubleBounce);
  });

  test('serve must land in opposite diagonal service court', () {
    final rules = MatchRulesSystem();
    final match = MatchState()..startPoint();
    final ball = BallState(
      x: Court.width * 0.75,
      y: Court.opponentKitchenTopY - 20,
      z: 0,
      lastHitBy: PlayerSide.player,
    );

    final result = rules.evaluateGroundContact(ball, match: match);

    expect(result.pointEnded, isTrue);
    expect(result.winner, PlayerSide.opponent);
    expect(result.fault, RuleFault.illegalServe);
  });

  test('serve landing in legal diagonal service court continues play', () {
    final rules = MatchRulesSystem();
    final match = MatchState()..startPoint();
    final ball = BallState(
      x: Court.width * 0.25,
      y: Court.opponentKitchenTopY - 20,
      z: 0,
      lastHitBy: PlayerSide.player,
    );

    final result = rules.evaluateGroundContact(ball, match: match);

    expect(result.pointEnded, isFalse);
  });

  test('serve landing in kitchen is a service fault', () {
    final rules = MatchRulesSystem();
    final match = MatchState()..startPoint();
    final ball = BallState(
      x: Court.width * 0.25,
      y: Court.opponentKitchenTopY + 1,
      z: 0,
      lastHitBy: PlayerSide.player,
    );

    final result = rules.evaluateGroundContact(ball, match: match);

    expect(result.pointEnded, isTrue);
    expect(result.winner, PlayerSide.opponent);
    expect(result.fault, RuleFault.illegalServe);
  });

  test('receiver volley before serve bounce violates two-bounce rule', () {
    final rules = MatchRulesSystem();
    final match = MatchState()..startPoint();
    final receiver = PlayerState(
      position: Vector2(110, Court.opponentStartY),
      side: PlayerSide.opponent,
    );
    final ball = BallState(x: 110, y: Court.opponentStartY, z: 30);

    final result = rules.evaluateVolley(
      hitter: receiver,
      ball: ball,
      match: match,
    );

    expect(result.pointEnded, isTrue);
    expect(result.winner, PlayerSide.player);
    expect(result.fault, RuleFault.twoBounceViolation);
  });

  test('server volley before return bounce violates two-bounce rule', () {
    final rules = MatchRulesSystem();
    final match = MatchState()
      ..startPoint()
      ..recordGroundBounce(PlayerSide.opponent);
    final server = PlayerState(
      position: Vector2(110, Court.playerStartY),
      side: PlayerSide.player,
    );
    final ball = BallState(
      x: 110,
      y: Court.playerStartY,
      z: 30,
      lastHitBy: PlayerSide.opponent,
    );

    final result = rules.evaluateVolley(
      hitter: server,
      ball: ball,
      match: match,
    );

    expect(result.pointEnded, isTrue);
    expect(result.winner, PlayerSide.opponent);
    expect(result.fault, RuleFault.twoBounceViolation);
  });

  test('volley outside kitchen is legal after both required bounces', () {
    final rules = MatchRulesSystem();
    final match = MatchState()
      ..startPoint()
      ..recordGroundBounce(PlayerSide.opponent)
      ..recordGroundBounce(PlayerSide.player);
    final player = PlayerState(
      position: Vector2(110, Court.playerKitchenBottomY + 30),
      side: PlayerSide.player,
    );
    final ball = BallState(x: 110, y: Court.playerKitchenBottomY + 30, z: 30);

    final result = rules.evaluateVolley(
      hitter: player,
      ball: ball,
      match: match,
    );

    expect(result.pointEnded, isFalse);
  });

  test('player kitchen volley awards point to opponent', () {
    final rules = MatchRulesSystem();
    final player = PlayerState(
      position: Vector2(110, Court.playerKitchenTopY + 10),
      side: PlayerSide.player,
    );
    final ball = BallState(x: 110, y: Court.playerKitchenTopY + 5, z: 30);

    final result = rules.evaluateVolley(hitter: player, ball: ball);

    expect(result.pointEnded, isTrue);
    expect(result.winner, PlayerSide.opponent);
    expect(result.fault, RuleFault.kitchenVolley);
  });

  test('opponent kitchen volley awards point to player', () {
    final rules = MatchRulesSystem();
    final opponent = PlayerState(
      position: Vector2(110, Court.opponentKitchenBottomY - 10),
      side: PlayerSide.opponent,
    );
    final ball = BallState(x: 110, y: Court.opponentKitchenBottomY - 5, z: 30);

    final result = rules.evaluateVolley(hitter: opponent, ball: ball);

    expect(result.pointEnded, isTrue);
    expect(result.winner, PlayerSide.player);
    expect(result.fault, RuleFault.kitchenVolley);
  });

  test('net contact awards point to non-hitting side', () {
    final rules = MatchRulesSystem();
    final ball = BallState(
      x: Court.width / 2,
      y: Court.netY,
      z: Court.netHeight * 0.5,
      lastHitBy: PlayerSide.player,
    );

    final result = rules.evaluatePhysicsResult(
      ball: ball,
      physics: const BallPhysicsResult(netContact: true),
    );

    expect(result.pointEnded, isTrue);
    expect(result.winner, PlayerSide.opponent);
    expect(result.fault, RuleFault.netCollision);
  });
}
