import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'components/ball_component.dart';
import 'components/court_component.dart';
import 'components/debug_overlay_component.dart';
import 'components/kitchen_zone_component.dart';
import 'components/net_component.dart';
import 'components/opponent_component.dart';
import 'components/player_component.dart';
import 'components/reset_button_component.dart';
import 'components/shadow_component.dart';
import 'config/court_constants.dart';
import 'models/shot_type.dart';
import 'systems/ball_physics_system.dart';
import 'systems/input_system.dart';
import 'systems/movement_system.dart';
import 'systems/opponent_ai_system.dart';
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

  int rallyCount = 0;

  double _courtScale = 1;
  Vector2 _courtOffset = Vector2.zero();
  int? _movementPointerId;
  int? _shotPointerId;
  Vector2? _shotStartPosition;
  Vector2? _shotLastPosition;
  double _shotHeldSeconds = 0;

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
    add(DebugOverlayComponent(this));
    add(ResetButtonComponent(this));
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    final projectedHeight = Court.length * CourtProjection.yCompression;
    _courtScale = (size.x * 0.86 / Court.width)
        .clamp(0.1, size.y * 0.84 / projectedHeight)
        .toDouble();
    _courtOffset = Vector2(
      (size.x - Court.width * _courtScale) / 2,
      (size.y - projectedHeight * _courtScale) / 2,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _shotHeldSeconds += _shotPointerId == null ? 0 : dt;

    movementSystem.update(
      player: player.state,
      inputX: inputSystem.movementX,
      inputY: inputSystem.movementY,
      hasInput: inputSystem.hasMovementInput,
      dt: dt,
    );

    for (final shotType in inputSystem.drainShots()) {
      shotSystem.attemptShot(
        ball: ball.state,
        hitter: player.state,
        opponent: opponent.state,
        shotType: shotType,
      );
    }

    final crossing = ballPhysicsSystem.update(ball.state, dt);
    if (crossing != null) {
      rallyCount++;
    }

    opponentAiSystem.update(
      ball: ball.state,
      opponent: opponent.state,
      player: player.state,
      shotSystem: shotSystem,
      dt: dt,
    );
  }

  Vector2 courtToWorld(Vector2 courtPosition, [double z = 0]) {
    final projected = CourtProjection.courtToScreen(courtPosition, z);
    return Vector2(
      _courtOffset.x + projected.x * _courtScale,
      _courtOffset.y + projected.y * _courtScale,
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
    opponent.state.position.setValues(Court.opponentStartX, Court.opponentStartY);
    opponent.state.velocity.setZero();
    rallyCount = 0;
    shotSystem.lastShotType = null;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final position = event.canvasPosition;
    if (position.x >= size.x / 2 && _shotPointerId == null) {
      _shotPointerId = event.pointerId;
      _shotStartPosition = position.clone();
      _shotLastPosition = position.clone();
      _shotHeldSeconds = 0;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (event.pointerId == _shotPointerId) {
      _queueShotForRelease(event.canvasPosition);
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    super.onTapCancel(event);
    if (event.pointerId == _shotPointerId) {
      _clearShotPointer();
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final position = event.canvasPosition;
    if (position.x < size.x / 2 && _movementPointerId == null) {
      _movementPointerId = event.pointerId;
      inputSystem.clearMovement();
      return;
    }
    if (position.x >= size.x / 2 && _shotPointerId == null) {
      _shotPointerId = event.pointerId;
      _shotStartPosition = position.clone();
      _shotLastPosition = position.clone();
      _shotHeldSeconds = 0;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (event.pointerId == _movementPointerId) {
      final delta = event.localDelta;
      inputSystem.setMovement(delta.x, delta.y);
    }
    if (event.pointerId == _shotPointerId) {
      _shotLastPosition = event.canvasEndPosition.clone();
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
    if (event.pointerId == _shotPointerId) {
      _queueShotForRelease(_shotLastPosition ?? _shotStartPosition ?? Vector2.zero());
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    if (event.pointerId == _movementPointerId) {
      _movementPointerId = null;
      inputSystem.clearMovement();
    }
    if (event.pointerId == _shotPointerId) {
      _clearShotPointer();
    }
  }

  void _queueShotForRelease(Vector2 endPosition) {
    final start = _shotStartPosition ?? endPosition;
    final moved = start.distanceTo(endPosition);
    inputSystem.queueShot(
      _shotHeldSeconds <= 0.15 && moved < 10 ? ShotType.dink : ShotType.drive,
    );
    _clearShotPointer();
  }

  void _clearShotPointer() {
    _shotPointerId = null;
    _shotStartPosition = null;
    _shotLastPosition = null;
    _shotHeldSeconds = 0;
  }
}
