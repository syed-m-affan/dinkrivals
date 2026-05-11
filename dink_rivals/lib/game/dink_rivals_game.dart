import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/ball_component.dart';
import 'components/classic_environment_component.dart';
import 'components/court_component.dart';
import 'components/debug_overlay_component.dart';
import 'components/kitchen_zone_component.dart';
import 'components/net_component.dart';
import 'components/opponent_component.dart';
import 'components/player_component.dart';
import 'components/racket_component.dart';
import 'components/rally_feedback_component.dart';
import 'components/score_component.dart';
import 'components/shadow_component.dart';
import 'components/touch_controls_component.dart';
import 'components/vfx/vfx_layer_component.dart';
import 'config/court_constants.dart';
import 'config/debug_flags.dart';
import 'config/tuning_constants.dart';
import 'models/ball_state.dart';
import 'models/gameplay_control_mode.dart';
import 'models/match_state.dart';
import 'models/opponent_serve_phase.dart';
import 'models/player_side.dart';
import 'models/rule_result.dart';
import 'models/shot_type.dart';
import 'models/swing_intent.dart';
import 'systems/ball_physics_system.dart';
import 'systems/court_layout_system.dart';
import 'systems/input_system.dart';
import 'systems/match_rules_system.dart';
import 'systems/movement_system.dart';
import 'systems/opponent_ai_system.dart';
import 'systems/scoring_system.dart';
import 'systems/serve_flow_system.dart';
import 'systems/shot_system.dart';
import 'systems/touch_input_controller.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';

class DinkRivalsGame extends FlameGame with TapCallbacks, DragCallbacks {
  DinkRivalsGame({
    AudioService? audioService,
    HapticsService? hapticsService,
    this.controlMode = GameplayControlMode.classicRacketStick,
  })  : audioService = audioService ?? FakeAudioService(),
        hapticsService = hapticsService ?? FakeHapticsService();

  late final PlayerComponent player;
  late final OpponentComponent opponent;
  late final BallComponent ball;
  late final VfxLayerComponent vfx;
  final AudioService audioService;
  final HapticsService hapticsService;
  final GameplayControlMode controlMode;

  final CourtLayoutSystem courtLayoutSystem = CourtLayoutSystem();
  final InputSystem inputSystem = InputSystem();
  final TouchInputController touchInputController = TouchInputController();
  final ServeFlowSystem serveFlowSystem = ServeFlowSystem();
  final MovementSystem movementSystem = MovementSystem();
  final ShotSystem shotSystem = ShotSystem();
  final BallPhysicsSystem ballPhysicsSystem = BallPhysicsSystem();
  final OpponentAISystem opponentAiSystem = OpponentAISystem();
  final MatchState matchState = MatchState();
  final ScoringSystem scoringSystem = ScoringSystem();
  final MatchRulesSystem matchRulesSystem = MatchRulesSystem();

  int rallyCount = 0;
  RuleResult? lastRuleResult;
  String feedbackText = '';
  double feedbackSeconds = 0;

  bool paused = false;
  final ValueNotifier<bool> matchOverNotifier = ValueNotifier<bool>(false);

  ValueNotifier<OpponentServePhase> get opponentServePhase =>
      serveFlowSystem.opponentServePhase;
  ValueNotifier<int> get opponentServeCountdown =>
      serveFlowSystem.opponentServeCountdown;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    player = PlayerComponent(this);
    opponent = OpponentComponent(this);
    ball = BallComponent(this);
    vfx = VfxLayerComponent(this);

    add(ClassicEnvironmentComponent(this));
    add(CourtComponent(this));
    add(KitchenZoneComponent(this));
    add(NetComponent(this));
    add(ShadowComponent(this));
    add(player);
    add(opponent);
    add(ball);
    add(RacketComponent(this));
    add(vfx);
    add(ScoreComponent(this));
    add(RallyFeedbackComponent(this));
    add(TouchControlsComponent(this));
    if (DebugFlags.showOverlay) {
      add(DebugOverlayComponent(this));
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    courtLayoutSystem.resize(size);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (paused) {
      return;
    }

    inputSystem.updateRacket(dt);
    _spawnMissForExpiredSwing();
    _startPlayerSwingAnimation();
    shotSystem.update(dt);

    if (_updateOpponentServeGate(dt)) {
      return;
    }

    _updatePlayerMovementAndServe(dt);
    if (_tryPlayerRacketContact()) {
      return;
    }
    _updateFeedback(dt);
    if (_updatePhysicsAndRules(dt)) {
      return;
    }
    _updateOpponentAiAndRules(dt);
  }

  Vector2 courtToWorld(Vector2 courtPosition, [double z = 0]) {
    return courtLayoutSystem.courtToWorld(courtPosition, z);
  }

  double logicalToScreen(double logicalUnits) {
    return courtLayoutSystem.logicalToScreen(logicalUnits);
  }

  double depthScaleForY(double courtY) {
    return courtLayoutSystem.depthScaleForY(courtY);
  }

  bool get isWaitingToServe {
    return serveFlowSystem.isWaitingForPlayerServe(
      ball: ball.state,
      matchState: matchState,
    );
  }

  bool get isServeCharging => serveFlowSystem.hasActivePlayerServeCharge;

  double get serveChargeFraction => serveFlowSystem.playerServeChargeFraction;

  void resetPoint() {
    ball.state
      ..x = Court.ballServeX
      ..y = Court.ballServeY
      ..z = 0
      ..vx = 0
      ..vy = 0
      ..vz = 0
      ..lastHitBy = null
      ..hasBouncedThisSide = false
      ..isInPlay = false
      ..arcGravityScale = 1;
    opponent.state.position
        .setValues(Court.opponentStartX, Court.opponentStartY);
    opponent.state.velocity.setZero();
    opponent.state.lastShotType = null;
    player.state.position.setValues(Court.playerStartX, Court.playerStartY);
    player.state.velocity.setZero();
    player.state.lastShotType = null;
    inputSystem.resetRacket();
    // Pointer IDs and movement state intentionally preserved so a player who
    // is still holding the movement / swing joystick keeps controlling the
    // player through point resets (see ticket P0-003). Flame's drag-end
    // callbacks clean up the pointer state when the finger actually lifts.
    rallyCount = 0;
    matchState.resetPoint();
    shotSystem.lastShotType = null;
    feedbackText = '';
    feedbackSeconds = 0;
    if (isLoaded) {
      vfx.clearBallTrail();
    }
    serveFlowSystem.clearPlayerServeCharge();
    serveFlowSystem.refreshOpponentServePhase(matchState);
  }

  void resetMatch() {
    scoringSystem.resetMatch(matchState);
    lastRuleResult = null;
    matchOverNotifier.value = false;
    if (isLoaded) {
      resetPoint();
    }
  }

  void confirmOpponentServeReady() {
    serveFlowSystem.confirmOpponentServeReady();
  }

  Vector2 playerRacketDirection() {
    return Vector2(
      math.sin(inputSystem.racketAngle),
      -math.cos(inputSystem.racketAngle),
    );
  }

  Vector2 playerRacketTangent() {
    return Vector2(
      math.cos(inputSystem.racketAngle),
      math.sin(inputSystem.racketAngle),
    );
  }

  Vector2 playerRacketPosition() {
    return player.state.position + playerRacketDirection() * Tuning.racketReach;
  }

  Vector2 opponentRacketPosition() {
    final ballPosition = Vector2(ball.state.x, ball.state.y);
    final direction = ballPosition - opponent.state.position;
    if (direction.length2 < 0.01) {
      direction.setValues(0, 1);
    }
    direction.normalize();
    return opponent.state.position + direction * Tuning.racketReach;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _handlePointerStart(event.pointerId, event.canvasPosition);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    _handlePointerEnd(event.pointerId);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    super.onTapCancel(event);
    _handlePointerCancel(event.pointerId);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _handlePointerStart(event.pointerId, event.canvasPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (serveFlowSystem.ownsPlayerServePointer(event.pointerId)) {
      return;
    }
    touchInputController.handlePointerUpdate(
      pointerId: event.pointerId,
      position: event.canvasEndPosition,
      size: size,
      canMove: !isWaitingToServe,
      inputSystem: inputSystem,
    );
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _handlePointerEnd(event.pointerId);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _handlePointerCancel(event.pointerId);
  }

  bool _updateOpponentServeGate(double dt) {
    return serveFlowSystem.updateOpponentServeGate(
      dt: dt,
      ball: ball.state,
      player: player.state,
      opponent: opponent.state,
      matchState: matchState,
      shotSystem: shotSystem,
      showFeedback: _showFeedback,
    );
  }

  void _updatePlayerMovementAndServe(double dt) {
    if (isWaitingToServe) {
      player.state.velocity.setZero();
      serveFlowSystem.updatePlayerServeCharge(dt);
      serveFlowSystem.glueBallToPlayerServeRacket(
        ball: ball.state,
        racketPosition: playerRacketPosition(),
      );
      return;
    }

    serveFlowSystem.clearPlayerServeCharge();
    movementSystem.update(
      player: player.state,
      inputX: inputSystem.movementX,
      inputY: inputSystem.movementY,
      hasInput: inputSystem.hasMovementInput,
      dt: dt,
    );
  }

  bool _tryPlayerRacketContact() {
    if (matchState.matchOver || !ball.state.isInPlay) {
      return false;
    }

    final preHitBall = BallState(
      x: ball.state.x,
      y: ball.state.y,
      z: ball.state.z,
      lastHitBy: ball.state.lastHitBy,
    );
    final command = inputSystem.activeSwingCommand;
    if (command == null && inputSystem.isRecoveringFromSwingMiss) {
      return false;
    }
    final didHit = shotSystem.attemptManualContact(
      ball: ball.state,
      hitter: player.state,
      racketPosition: playerRacketPosition(),
      aimDirection: command?.aimDirection ?? playerRacketDirection(),
      swipeDirection: command?.swipeDirection,
      intent: command?.intent,
      power: command?.power ?? 0,
    );
    if (!didHit) {
      return false;
    }

    audioService.playHit();
    hapticsService.light();
    player.showHitConfirm();
    inputSystem.consumeSwingCommand();
    _showFeedback(shotSystem.lastShotType?.name.toUpperCase() ?? 'HIT');
    vfx.spawnContact(
      courtPosition: Vector2(preHitBall.x, preHitBall.y),
      z: preHitBall.z,
      shotType: shotSystem.lastShotType,
    );
    if (!matchState.pointInProgress) {
      matchState.startPoint();
    }
    final volleyResult = matchRulesSystem.evaluateVolley(
      hitter: player.state,
      ball: preHitBall,
      match: matchState,
    );
    if (volleyResult.pointEnded) {
      _awardPoint(volleyResult);
      return true;
    }
    return false;
  }

  void _startPlayerSwingAnimation() {
    final command = inputSystem.activeSwingCommand;
    if (command == null || command.animationStarted) {
      return;
    }
    player.state
      ..isSwinging = true
      ..lastShotType = switch (command.intent) {
        SwingIntent.dink => ShotType.dink,
        SwingIntent.drive => ShotType.drive,
        SwingIntent.lob => ShotType.lob,
        SwingIntent.smash => ShotType.smash,
      };
    inputSystem.markSwingAnimationStarted();
  }

  void _spawnMissForExpiredSwing() {
    final command = inputSystem.consumeExpiredSwingCommand();
    if (command == null || matchState.matchOver || !ball.state.isInPlay) {
      return;
    }
    vfx.spawnSwingMiss(
      hitter: player.state,
      intent: command.intent,
      swipeDirection: command.swipeDirection,
    );
    _showFeedback('MISS');
  }

  void _updateFeedback(double dt) {
    if (feedbackSeconds <= 0) {
      return;
    }
    feedbackSeconds = math.max(0, feedbackSeconds - dt);
    if (feedbackSeconds == 0) {
      feedbackText = '';
    }
  }

  bool _updatePhysicsAndRules(double dt) {
    final physics = ballPhysicsSystem.update(ball.state, dt);
    if (physics.groundContact) {
      audioService.playBounce();
      vfx.spawnBounce(courtPosition: Vector2(ball.state.x, ball.state.y));
    }
    if (physics.crossedNet) {
      scoringSystem.recordRallyCrossing(matchState);
      rallyCount = matchState.rallyCount;
    }
    final ruleResult = matchRulesSystem.evaluatePhysicsResult(
      ball: ball.state,
      physics: physics,
      match: matchState,
    );
    if (ruleResult.pointEnded) {
      _awardPoint(ruleResult);
      return true;
    }
    if (physics.groundContact) {
      matchState.recordGroundBounce(ball.state.currentSide);
    }
    if (physics.groundContact &&
        !ball.state.isInPlay &&
        ball.state.lastHitBy != null) {
      _awardPoint(
        RuleResult.point(
          winner: ball.state.lastHitBy!,
          fault: RuleFault.doubleBounce,
        ),
      );
      return true;
    }
    return false;
  }

  void _updateOpponentAiAndRules(double dt) {
    final preAiBall = BallState(
      x: ball.state.x,
      y: ball.state.y,
      z: ball.state.z,
      lastHitBy: ball.state.lastHitBy,
    );
    final preAiLastHitBy = ball.state.lastHitBy;
    opponentAiSystem.update(
      ball: ball.state,
      matchState: matchState,
      opponent: opponent.state,
      player: player.state,
      shotSystem: shotSystem,
      dt: dt,
    );
    if (ball.state.lastHitBy != preAiLastHitBy &&
        ball.state.lastHitBy == opponent.state.side) {
      audioService.playHit();
      opponent.showHitConfirm();
      _showFeedback(shotSystem.lastShotType?.name.toUpperCase() ?? 'HIT');
      vfx.spawnContact(
        courtPosition: Vector2(preAiBall.x, preAiBall.y),
        z: preAiBall.z,
        shotType: shotSystem.lastShotType,
      );
      final volleyResult = matchRulesSystem.evaluateVolley(
        hitter: opponent.state,
        ball: preAiBall,
        match: matchState,
      );
      if (volleyResult.pointEnded) {
        _awardPoint(volleyResult);
      }
    }
  }

  void _awardPoint(RuleResult result) {
    final winner = result.winner;
    if (winner == null) {
      return;
    }
    lastRuleResult = result;
    _showFeedback(_feedbackForRule(result));
    final isFault = result.fault != null;
    if (isFault) {
      audioService.playFault();
    }
    final changed = scoringSystem.awardPoint(matchState, winner);
    if (changed) {
      audioService.playPoint();
      if (winner == PlayerSide.player) {
        hapticsService.medium();
      }
    }
    player.showPointResult(winner);
    opponent.showPointResult(winner);
    vfx.spawnPointBurst(courtPosition: Vector2(Court.width / 2, Court.netY));
    resetPoint();
    if (matchState.matchOver) {
      ball.state.isInPlay = false;
      matchOverNotifier.value = true;
    }
  }

  void _showFeedback(String text) {
    feedbackText = text;
    feedbackSeconds = 1.1;
  }

  String _feedbackForRule(RuleResult result) {
    final fault = result.fault;
    if (fault == null) {
      return 'POINT';
    }
    return switch (fault) {
      RuleFault.outOfBounds => 'FAULT: OUT',
      RuleFault.doubleBounce => 'FAULT: DOUBLE BOUNCE',
      RuleFault.twoBounceViolation => 'FAULT: TWO BOUNCE',
      RuleFault.kitchenVolley => 'FAULT: KITCHEN',
      RuleFault.illegalServe => 'FAULT: SERVE',
    };
  }

  void _handlePointerStart(int pointerId, Vector2 position) {
    final layout = TouchControlLayout(size);
    if (layout.isInServeButton(position) &&
        serveFlowSystem.beginPlayerServeCharge(
          pointerId: pointerId,
          isWaitingToServe: isWaitingToServe,
          paused: paused,
        )) {
      return;
    }
    touchInputController.handlePointerStart(
      pointerId: pointerId,
      position: position,
      size: size,
      canMove: !isWaitingToServe,
      inputSystem: inputSystem,
    );
  }

  void _handlePointerEnd(int pointerId) {
    if (serveFlowSystem.releasePlayerServe(
      pointerId: pointerId,
      ball: ball.state,
      player: player.state,
      matchState: matchState,
      shotSystem: shotSystem,
      racketPosition: playerRacketPosition(),
      racketDirection: playerRacketDirection(),
      paused: paused,
      showFeedback: _showFeedback,
    )) {
      return;
    }
    touchInputController.handlePointerEnd(
      pointerId: pointerId,
      size: size,
      inputSystem: inputSystem,
    );
  }

  void _handlePointerCancel(int pointerId) {
    if (serveFlowSystem.cancelPlayerServeCharge(pointerId)) {
      return;
    }
    touchInputController.handlePointerEnd(
      pointerId: pointerId,
      size: size,
      inputSystem: inputSystem,
    );
  }
}
