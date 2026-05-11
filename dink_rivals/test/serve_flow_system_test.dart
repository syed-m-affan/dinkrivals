import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/models/ball_state.dart';
import 'package:dink_rivals/game/models/match_state.dart';
import 'package:dink_rivals/game/models/opponent_serve_phase.dart';
import 'package:dink_rivals/game/models/player_side.dart';
import 'package:dink_rivals/game/models/player_state.dart';
import 'package:dink_rivals/game/systems/serve_flow_system.dart';
import 'package:dink_rivals/game/systems/shot_system.dart';

void main() {
  test('player serve charge starts, advances, and releases into play', () {
    final serveFlow = ServeFlowSystem();
    final ball = BallState(x: Court.ballServeX, y: Court.ballServeY, z: 0);
    final matchState = MatchState();
    final player = PlayerState(
      position: Vector2(Court.playerStartX, Court.playerStartY),
      side: PlayerSide.player,
    );
    final shotSystem = ShotSystem();
    var feedback = '';

    final started = serveFlow.beginPlayerServeCharge(
      pointerId: 1,
      isWaitingToServe: serveFlow.isWaitingForPlayerServe(
        ball: ball,
        matchState: matchState,
      ),
      paused: false,
    );
    serveFlow.updatePlayerServeCharge(0.6);

    expect(started, isTrue);
    expect(serveFlow.playerServeChargeFraction, greaterThan(0));

    final handled = serveFlow.releasePlayerServe(
      pointerId: 1,
      ball: ball,
      player: player,
      matchState: matchState,
      shotSystem: shotSystem,
      racketPosition: player.position + Vector2(0, -40),
      racketDirection: Vector2(0, -1),
      paused: false,
      showFeedback: (text) => feedback = text,
    );

    expect(handled, isTrue);
    expect(ball.isInPlay, isTrue);
    expect(matchState.pointInProgress, isTrue);
    expect(feedback, startsWith('SERVE'));
  });

  test('opponent serve gate blocks simulation until countdown executes serve',
      () {
    final serveFlow = ServeFlowSystem();
    final ball = BallState(x: Court.ballServeX, y: Court.ballServeY, z: 0);
    final matchState = MatchState(servingSide: PlayerSide.opponent);
    final player = PlayerState(
      position: Vector2(Court.playerStartX, Court.playerStartY),
      side: PlayerSide.player,
    );
    final opponent = PlayerState(
      position: Vector2(Court.opponentStartX, Court.opponentStartY),
      side: PlayerSide.opponent,
    );
    final shotSystem = ShotSystem();

    serveFlow.refreshOpponentServePhase(matchState);
    expect(
        serveFlow.opponentServePhase.value, OpponentServePhase.awaitingReady);

    serveFlow.confirmOpponentServeReady();
    expect(serveFlow.opponentServePhase.value, OpponentServePhase.countingDown);

    final blocked = serveFlow.updateOpponentServeGate(
      dt: ServeFlowSystem.opponentServeCountdownSeconds,
      ball: ball,
      player: player,
      opponent: opponent,
      matchState: matchState,
      shotSystem: shotSystem,
      showFeedback: (_) {},
    );

    expect(blocked, isTrue);
    expect(ball.isInPlay, isTrue);
    expect(ball.lastHitBy, PlayerSide.opponent);
    expect(serveFlow.opponentServePhase.value, OpponentServePhase.none);
  });
}
