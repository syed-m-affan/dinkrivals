import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/config/tuning_constants.dart';
import 'package:dink_rivals/game/models/ball_state.dart';
import 'package:dink_rivals/game/models/match_state.dart';
import 'package:dink_rivals/game/models/player_side.dart';
import 'package:dink_rivals/game/models/player_state.dart';
import 'package:dink_rivals/game/systems/opponent_ai_system.dart';
import 'package:dink_rivals/game/systems/shot_system.dart';

void main() {
  test('opponent waits for serve bounce before attempting return', () {
    final ai = OpponentAISystem(random: math.Random(1));
    final shotSystem = ShotSystem(random: math.Random(1));
    final match = MatchState()..startPoint();
    final opponent = PlayerState(
      position: Vector2(Court.width / 2, Court.opponentStartY),
      side: PlayerSide.opponent,
    );
    final player = PlayerState(
      position: Vector2(Court.width / 2, Court.playerStartY),
      side: PlayerSide.player,
    );
    final ball = BallState(
      x: opponent.position.x,
      y: opponent.position.y + Tuning.racketReach,
      z: Tuning.racketContactZ,
      vy: -80,
      lastHitBy: PlayerSide.player,
      isInPlay: true,
    );

    ai.update(
      ball: ball,
      matchState: match,
      opponent: opponent,
      player: player,
      shotSystem: shotSystem,
      dt: 0.16,
    );

    expect(ball.lastHitBy, PlayerSide.player);
    expect(shotSystem.lastShotType, isNull);
  });
}
