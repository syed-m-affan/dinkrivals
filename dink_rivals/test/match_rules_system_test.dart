import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/models/ball_state.dart';
import 'package:dink_rivals/game/models/player_side.dart';
import 'package:dink_rivals/game/models/player_state.dart';
import 'package:dink_rivals/game/models/rule_result.dart';
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
}
