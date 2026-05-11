import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/ball_component.dart';
import 'components/court_component.dart';
import 'components/debug_overlay_component.dart';
import 'components/kitchen_zone_component.dart';
import 'components/net_component.dart';
import 'components/opponent_component.dart';
import 'components/player_component.dart';
import 'components/rally_feedback_component.dart';
import 'components/score_component.dart';
import 'components/shadow_component.dart';
import 'config/court_constants.dart';
import 'config/tuning_constants.dart';
import 'models/ball_state.dart';
import 'models/match_state.dart';
import 'models/rule_result.dart';
import 'systems/ball_physics_system.dart';
import 'systems/input_system.dart';
import 'systems/match_rules_system.dart';
import 'systems/movement_system.dart';
import 'systems/opponent_ai_system.dart';
import 'systems/scoring_system.dart';
import 'systems/shot_system.dart';
import 'util/court_projection.dart';

class DinkRivalsGame extends FlameGame with TapCallbacks, DragCallbacks {
  late final PlayerComponent player;
  late final OpponentComponent opponent;
  late final BallComponent ball;

  final InputSystem inputSystem = InputSystem();
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

  double _courtScale = 1;
  Vector2 _courtOffset = Vector2.zero();
  int? _movementPointerId;
  int? _swingPointerId;
  Vector2? _swingLastPosition;
  Vector2 _projectedMin = Vector2.zero();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    player = PlayerComponent(this);
    opponent = OpponentComponent(this);
    ball = BallComponent(this);

    add(CourtComponent(this));
    add(KitchenZoneComponent(this));
    add(NetComponent(this));
    add(ShadowComponent(this));
    add(player);
    add(opponent);
    add(ball);
    add(ScoreComponent(this));
    add(RallyFeedbackComponent(this));
    add(DebugOverlayComponent(this));
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final projectedCorners = <Vector2>[
      CourtProjection.courtToScreen(Vector2(Court.left, Court.top), 0),
      CourtProjection.courtToScreen(Vector2(Court.right, Court.top), 0),
      CourtProjection.courtToScreen(Vector2(Court.right, Court.bottom), 0),
      CourtProjection.courtToScreen(Vector2(Court.left, Court.bottom), 0),
    ];
    final minX = projectedCorners
        .map((corner) => corner.x)
        .reduce((a, b) => a < b ? a : b);
    final maxX = projectedCorners
        .map((corner) => corner.x)
        .reduce((a, b) => a > b ? a : b);
    final minY = projectedCorners
        .map((corner) => corner.y)
        .reduce((a, b) => a < b ? a : b);
    final maxY = projectedCorners
        .map((corner) => corner.y)
        .reduce((a, b) => a > b ? a : b);
    final projectedWidth = maxX - minX;
    final projectedHeight = maxY - minY;
    _projectedMin = Vector2(minX, minY);
    _courtScale = (size.x * 0.99 / projectedWidth)
        .clamp(0.1, size.y * 0.94 / projectedHeight)
        .toDouble();
    _courtOffset = Vector2(
      (size.x - projectedWidth * _courtScale) / 2,
      (size.y - projectedHeight * _courtScale) / 2,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _renderRackets(canvas);
    _renderTouchControls(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (paused) {
      return;
    }
    inputSystem.updateRacket(dt);
    shotSystem.update(dt);

    movementSystem.update(
      player: player.state,
      inputX: inputSystem.movementX,
      inputY: inputSystem.movementY,
      hasInput: inputSystem.hasMovementInput,
      dt: dt,
    );

    if (!ball.state.isInPlay && !matchState.matchOver) {
      // Serve state: ball follows the racket tip until the player taps SERVE.
      final racketTip = playerRacketPosition();
      ball.state.x = racketTip.x;
      ball.state.y = racketTip.y;
      ball.state.z = 0;
    }

    if (!matchState.matchOver && ball.state.isInPlay) {
      final preHitBall = BallState(
        x: ball.state.x,
        y: ball.state.y,
        z: ball.state.z,
        lastHitBy: ball.state.lastHitBy,
      );
      final racketDirection = playerRacketDirection();
      final didHit = shotSystem.attemptRacketContact(
        ball: ball.state,
        hitter: player.state,
        racketPosition: playerRacketPosition(),
        racketDirection: racketDirection,
        racketVelocity: player.state.velocity +
            playerRacketTangent() *
                (inputSystem.racketAngularVelocity * Tuning.racketReach),
      );
      if (didHit) {
        _showFeedback(shotSystem.lastShotType?.name.toUpperCase() ?? 'HIT');
        if (!matchState.pointInProgress) {
          matchState.startPoint();
        }
        final volleyResult = matchRulesSystem.evaluateVolley(
          hitter: player.state,
          ball: preHitBall,
        );
        if (volleyResult.pointEnded) {
          _awardPoint(volleyResult);
          return;
        }
      }
    }

    if (feedbackSeconds > 0) {
      feedbackSeconds = math.max(0, feedbackSeconds - dt);
      if (feedbackSeconds == 0) {
        feedbackText = '';
      }
    }

    final physics = ballPhysicsSystem.update(ball.state, dt);
    if (physics.crossedNet) {
      scoringSystem.recordRallyCrossing(matchState);
      rallyCount = matchState.rallyCount;
    }
    final ruleResult = matchRulesSystem.evaluatePhysicsResult(
      ball: ball.state,
      physics: physics,
    );
    if (ruleResult.pointEnded) {
      _awardPoint(ruleResult);
      return;
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
      return;
    }

    final preAiBall = BallState(
      x: ball.state.x,
      y: ball.state.y,
      z: ball.state.z,
      lastHitBy: ball.state.lastHitBy,
    );
    final preAiLastHitBy = ball.state.lastHitBy;
    opponentAiSystem.update(
      ball: ball.state,
      opponent: opponent.state,
      player: player.state,
      shotSystem: shotSystem,
      dt: dt,
    );
    if (ball.state.lastHitBy != preAiLastHitBy &&
        ball.state.lastHitBy == opponent.state.side) {
      _showFeedback(shotSystem.lastShotType?.name.toUpperCase() ?? 'HIT');
      final volleyResult = matchRulesSystem.evaluateVolley(
        hitter: opponent.state,
        ball: preAiBall,
      );
      if (volleyResult.pointEnded) {
        _awardPoint(volleyResult);
      }
    }
  }

  Vector2 courtToWorld(Vector2 courtPosition, [double z = 0]) {
    final projected = CourtProjection.courtToScreen(courtPosition, z);
    return Vector2(
      _courtOffset.x + (projected.x - _projectedMin.x) * _courtScale,
      _courtOffset.y + (projected.y - _projectedMin.y) * _courtScale,
    );
  }

  double logicalToScreen(double logicalUnits) {
    return logicalUnits * _courtScale;
  }

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
    player.state.position
        .setValues(Court.playerStartX, Court.playerStartY);
    player.state.velocity.setZero();
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
  }

  void resetMatch() {
    matchState.playerScore = 0;
    matchState.opponentScore = 0;
    matchState.matchOver = false;
    matchState.longestRally = 0;
    matchState.playerDinkContactsThisMatch = 0;
    matchState.playerSmashContactsThisMatch = 0;
    lastRuleResult = null;
    matchOverNotifier.value = false;
    if (isLoaded) {
      resetPoint();
    }
  }

  void _awardPoint(RuleResult result) {
    final winner = result.winner;
    if (winner == null) {
      return;
    }
    lastRuleResult = result;
    _showFeedback(_feedbackForRule(result));
    scoringSystem.awardPoint(matchState, winner);
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
      RuleFault.kitchenVolley => 'FAULT: KITCHEN',
    };
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final position = event.canvasPosition;
    if (_isInServeButton(position)) {
      _triggerServe();
      return;
    }
    if (_isInMoveControl(position) && _movementPointerId == null) {
      _movementPointerId = event.pointerId;
      _setJoystickFromPosition(position);
      return;
    }
    if (_isInSwingControl(position) && _swingPointerId == null) {
      _swingPointerId = event.pointerId;
      _swingLastPosition = position.clone();
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (event.pointerId == _movementPointerId) {
      _movementPointerId = null;
      inputSystem.clearMovement();
      return;
    }
    if (event.pointerId == _swingPointerId) {
      _clearSwingPointer();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    super.onTapCancel(event);
    if (event.pointerId == _movementPointerId) {
      _movementPointerId = null;
      inputSystem.clearMovement();
    }
    if (event.pointerId == _swingPointerId) {
      _clearSwingPointer();
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final position = event.canvasPosition;
    if (_isInServeButton(position)) {
      _triggerServe();
      return;
    }
    if (_isInMoveControl(position) && _movementPointerId == null) {
      _movementPointerId = event.pointerId;
      _setJoystickFromPosition(position);
      return;
    }
    if (_isInSwingControl(position) && _swingPointerId == null) {
      _swingPointerId = event.pointerId;
      _swingLastPosition = position.clone();
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (event.pointerId == _movementPointerId) {
      _setJoystickFromPosition(event.canvasEndPosition);
    }
    if (event.pointerId == _swingPointerId) {
      _swingRacketFromPosition(event.canvasEndPosition);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (event.pointerId == _movementPointerId) {
      _movementPointerId = null;
      inputSystem.clearMovement();
      return;
    }
    if (event.pointerId == _swingPointerId) {
      _clearSwingPointer();
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    if (event.pointerId == _movementPointerId) {
      _movementPointerId = null;
      inputSystem.clearMovement();
    }
    if (event.pointerId == _swingPointerId) {
      _clearSwingPointer();
    }
  }

  void _clearSwingPointer() {
    _swingPointerId = null;
    _swingLastPosition = null;
  }

  Vector2 get _serveButtonCenter => Vector2(size.x * 0.5, size.y - 96);

  double get _serveButtonRadius => 44;

  bool _isInServeButton(Vector2 position) {
    if (ball.state.isInPlay) {
      return false;
    }
    return position.distanceTo(_serveButtonCenter) <= _serveButtonRadius;
  }

  void _triggerServe() {
    if (ball.state.isInPlay || matchState.matchOver || paused) {
      return;
    }
    final racketTip = playerRacketPosition();
    ball.state.x = racketTip.x;
    ball.state.y = racketTip.y;
    ball.state.z = 0;
    shotSystem.serve(
      ball: ball.state,
      hitter: player.state,
      racketDirection: playerRacketDirection(),
    );
    if (!matchState.pointInProgress) {
      matchState.startPoint();
    }
    _showFeedback('SERVE');
  }

  Vector2 get _joystickCenter => Vector2(size.x * 0.24, size.y - 118);

  double get _joystickRadius => 58;

  Vector2 get _swingJoystickCenter => Vector2(size.x * 0.78, size.y - 132);

  double get _swingJoystickRadius => 58;

  bool _isInMoveControl(Vector2 position) {
    return position.distanceTo(_joystickCenter) <= _joystickRadius * 1.35;
  }

  void _setJoystickFromPosition(Vector2 position) {
    final offset = position - _joystickCenter;
    final clamped = offset.length > _joystickRadius
        ? (offset.normalized()..scale(_joystickRadius))
        : offset;
    inputSystem.setMovement(
      clamped.x / _joystickRadius,
      clamped.y / _joystickRadius,
    );
  }

  bool _isInSwingControl(Vector2 position) {
    return position.x >= size.x / 2 &&
        position.distanceTo(_swingJoystickCenter) <=
            _swingJoystickRadius * 1.45;
  }

  void _swingRacketFromPosition(Vector2 position) {
    final previous = _swingLastPosition ?? position;
    final delta = position - previous;
    inputSystem.swingRacket(
      delta.x * Tuning.racketSwingRadiansPerPixel,
      Tuning.maxRacketAngleRadians,
    );
    _swingLastPosition = position.clone();
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

  Vector2 _opponentRacketPosition() {
    final ballPosition = Vector2(ball.state.x, ball.state.y);
    final direction = ballPosition - opponent.state.position;
    if (direction.length2 < 0.01) {
      direction.setValues(0, 1);
    }
    direction.normalize();
    return opponent.state.position + direction * Tuning.racketReach;
  }

  void _renderRackets(Canvas canvas) {
    final playerStart = courtToWorld(player.state.position);
    final playerEnd = courtToWorld(playerRacketPosition());
    final opponentStart = courtToWorld(opponent.state.position);
    final opponentEnd = courtToWorld(_opponentRacketPosition());
    final playerPaint = Paint()
      ..color = const Color(0xAA4AA3FF)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final opponentPaint = Paint()
      ..color = const Color(0x99FF5A5A)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    _drawRacket(canvas, playerStart, playerEnd, playerPaint);
    _drawRacket(canvas, opponentStart, opponentEnd, opponentPaint);
  }

  void _drawRacket(Canvas canvas, Vector2 start, Vector2 end, Paint paint) {
    final direction = end - start;
    if (direction.length < 1) {
      return;
    }
    canvas.drawLine(start.toOffset(), end.toOffset(), paint);
    canvas.drawCircle(end.toOffset(), 6, paint);
  }

  void _renderTouchControls(Canvas canvas) {
    final joystickCenter = _joystickCenter;
    final stickVector = Vector2(inputSystem.movementX, inputSystem.movementY);
    if (stickVector.length > 1) {
      stickVector.normalize();
    }
    final knobCenter = joystickCenter + stickVector * (_joystickRadius * 0.62);

    final controlPaint = Paint()..color = const Color(0x55303030);
    final strokePaint = Paint()
      ..color = const Color(0xAAFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final knobPaint = Paint()..color = const Color(0xAA4AA3FF);

    canvas.drawCircle(joystickCenter.toOffset(), _joystickRadius, controlPaint);
    canvas.drawCircle(joystickCenter.toOffset(), _joystickRadius, strokePaint);
    canvas.drawCircle(knobCenter.toOffset(), 23, knobPaint);
    canvas.drawCircle(knobCenter.toOffset(), 23, strokePaint);

    final swingCenter = _swingJoystickCenter;
    final swingKnobCenter = swingCenter +
        Vector2(
              math.sin(inputSystem.racketAngle),
              -math.cos(inputSystem.racketAngle),
            ) *
            (_swingJoystickRadius * 0.62);
    final swingPaint = Paint()..color = const Color(0xAA4FD08B);
    canvas.drawArc(
      Rect.fromCircle(
          center: swingCenter.toOffset(), radius: _swingJoystickRadius),
      math.pi,
      -math.pi,
      false,
      Paint()
        ..color = const Color(0x55303030)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _swingJoystickRadius * 0.62,
    );
    canvas.drawCircle(
        swingCenter.toOffset(), _swingJoystickRadius, strokePaint);
    canvas.drawCircle(swingKnobCenter.toOffset(), 19, swingPaint);
    canvas.drawCircle(swingKnobCenter.toOffset(), 19, strokePaint);

    final swingText = TextPainter(
      text: const TextSpan(
        text: 'SWING',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: _swingJoystickRadius * 2);
    swingText.paint(
      canvas,
      Offset(swingCenter.x - swingText.width / 2,
          swingCenter.y - _swingJoystickRadius - 22),
    );

    if (!ball.state.isInPlay && !matchState.matchOver) {
      final serveCenter = _serveButtonCenter;
      final serveFill = Paint()..color = const Color(0xCCFFCB47);
      final serveStroke = Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(
          serveCenter.toOffset(), _serveButtonRadius, serveFill);
      canvas.drawCircle(
          serveCenter.toOffset(), _serveButtonRadius, serveStroke);
      final serveText = TextPainter(
        text: const TextSpan(
          text: 'SERVE',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: _serveButtonRadius * 2);
      serveText.paint(
        canvas,
        Offset(serveCenter.x - serveText.width / 2,
            serveCenter.y - serveText.height / 2),
      );
    }
  }
}
