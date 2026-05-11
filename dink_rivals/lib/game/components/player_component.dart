import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/debug_flags.dart';
import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';
import '../models/player_side.dart';
import '../models/player_state.dart';
import '../util/projected_shadow.dart';

class PlayerComponent extends Component {
  PlayerComponent(this.game)
      : state = PlayerState(
          position: Vector2(Court.playerStartX, Court.playerStartY),
          side: PlayerSide.player,
        );

  final DinkRivalsGame game;
  final PlayerState state;
  final Paint _bodyPaint = Paint()..color = VisualPalette.playerPrimary;
  final Paint _headPaint = Paint()..color = VisualPalette.playerSkin;

  ui.Image? _idleSheet;
  ui.Image? _runSheet;
  ui.Image? _swingSheet;
  ui.Image? _readySheet;
  ui.Image? _hitConfirmSheet;
  ui.Image? _pointWinSheet;
  ui.Image? _pointLossSheet;
  double _animationSeconds = 0;
  double _swingSeconds = 0;
  double _hitConfirmSeconds = 0;
  double _pointResultSeconds = 0;
  bool _pendingHitConfirm = false;

  static const double _runThreshold = 12;
  static const double _spriteWidth = 34;
  static const double _spriteHeight = 51;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (!DebugFlags.useSprites) {
      return;
    }
    _idleSheet = await game.images.load('sprites/player_idle.png');
    _runSheet = await game.images.load('sprites/player_run.png');
    _swingSheet = await game.images.load('sprites/player_swing.png');
    _readySheet = await game.images.load('sprites/player_ready.png');
    _hitConfirmSheet = await game.images.load('sprites/player_hit_confirm.png');
    _pointWinSheet = await game.images.load('sprites/player_point_win.png');
    _pointLossSheet = await game.images.load('sprites/player_point_loss.png');
  }

  @override
  void update(double dt) {
    priority = state.position.y.round();
    _animationSeconds += dt;
    if (state.isSwinging) {
      _swingSeconds = 3 / 18;
      state.isSwinging = false;
    }
    var startedHitConfirm = false;
    if (_swingSeconds > 0) {
      _swingSeconds = (_swingSeconds - dt).clamp(0, 1).toDouble();
      if (_swingSeconds == 0 && _pendingHitConfirm) {
        _hitConfirmSeconds = 0.16;
        _pendingHitConfirm = false;
        startedHitConfirm = true;
      }
    } else if (_pendingHitConfirm) {
      _hitConfirmSeconds = 0.16;
      _pendingHitConfirm = false;
      startedHitConfirm = true;
    }
    if (_hitConfirmSeconds > 0 && !startedHitConfirm) {
      _hitConfirmSeconds = (_hitConfirmSeconds - dt).clamp(0, 1).toDouble();
    }
    if (_pointResultSeconds > 0) {
      _pointResultSeconds = (_pointResultSeconds - dt).clamp(0, 1).toDouble();
    }
  }

  @override
  void render(Canvas canvas) {
    _renderGroundShadow(canvas);
    if (DebugFlags.useSprites && _renderSprite(canvas)) {
      return;
    }
    _renderPrimitive(canvas);
  }

  bool _renderSprite(Canvas canvas) {
    final pose = _currentPose();
    final sheet = switch (pose) {
      _PlayerPose.idle => _idleSheet,
      _PlayerPose.run => _runSheet,
      _PlayerPose.swing => _swingSheet,
      _PlayerPose.ready => _readySheet,
      _PlayerPose.hitConfirm => _hitConfirmSheet,
      _PlayerPose.pointWin => _pointWinSheet,
      _PlayerPose.pointLoss => _pointLossSheet,
    };
    if (sheet == null) {
      return false;
    }
    final frames = switch (pose) {
      _PlayerPose.idle => 2,
      _PlayerPose.run => 4,
      _PlayerPose.swing => 3,
      _PlayerPose.ready => 2,
      _PlayerPose.hitConfirm => 2,
      _PlayerPose.pointWin => 2,
      _PlayerPose.pointLoss => 2,
    };
    final fps = switch (pose) {
      _PlayerPose.idle => 2,
      _PlayerPose.run => 8,
      _PlayerPose.swing => 18,
      _PlayerPose.ready => 3,
      _PlayerPose.hitConfirm => 12,
      _PlayerPose.pointWin => 4,
      _PlayerPose.pointLoss => 3,
    };
    final frame = ((_animationSeconds * fps).floor() % frames).toInt();
    final frameWidth = sheet.width / frames;
    final src = Rect.fromLTWH(
        frameWidth * frame, 0, frameWidth, sheet.height.toDouble());
    final scale = game.depthScaleForY(state.position.y);
    final feet = game.courtToWorld(state.position);
    final size = Size(
      game.logicalToScreen(_spriteWidth * scale),
      game.logicalToScreen(_spriteHeight * scale),
    );
    final dst = Rect.fromLTWH(
      feet.x - size.width / 2,
      feet.y - size.height,
      size.width,
      size.height,
    );
    canvas.drawImageRect(
        sheet, src, dst, Paint()..filterQuality = FilterQuality.none);
    return true;
  }

  _PlayerPose _currentPose() {
    if (_swingSeconds > 0) {
      return _PlayerPose.swing;
    }
    if (!game.matchState.pointInProgress) {
      return _PlayerPose.idle;
    }
    if (_hitConfirmSeconds > 0 || _pointResultSeconds > 0) {
      return _PlayerPose.idle;
    }
    if (state.velocity.length > _runThreshold) {
      return _PlayerPose.run;
    }
    return _PlayerPose.idle;
  }

  @visibleForTesting
  String currentPoseNameForTesting() => _currentPose().name;

  void showHitConfirm() {
    if (_swingSeconds > 0 || state.isSwinging) {
      _pendingHitConfirm = true;
      return;
    }
    _hitConfirmSeconds = 0.16;
  }

  void showPointResult(PlayerSide winner) {
    _pendingHitConfirm = false;
    _hitConfirmSeconds = 0;
    _pointResultSeconds = 0.72;
  }

  void _renderGroundShadow(Canvas canvas) {
    if (!DebugFlags.useProjectedShadows) {
      return;
    }
    final depthScale = game.depthScaleForY(state.position.y);
    final feet = game.courtToWorld(state.position);
    final width = game.logicalToScreen(16 * depthScale);
    final height = game.logicalToScreen(5.5 * depthScale);
    final rect = ProjectedShadow.directionalOvalRect(
      center: feet.toOffset(),
      width: width,
      height: height,
      offsetScale: 0.7,
    );
    canvas.drawOval(rect, ProjectedShadow.paint(0.22));
  }

  void _renderPrimitive(Canvas canvas) {
    final depthScale = game.depthScaleForY(state.position.y);
    final feet = game.courtToWorld(state.position);
    final torso = game.courtToWorld(state.position, 16);
    final head = game.courtToWorld(state.position, 28);
    final bodyRadius = game.logicalToScreen(7.4 * depthScale);
    final headRadius = game.logicalToScreen(5.6 * depthScale);

    canvas.drawLine(
      feet.toOffset(),
      torso.toOffset(),
      Paint()
        ..color = _bodyPaint.color
        ..strokeWidth = bodyRadius * 1.35
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(torso.toOffset(), bodyRadius, _bodyPaint);
    canvas.drawCircle(head.toOffset(), headRadius, _headPaint);
  }
}

enum _PlayerPose {
  idle,
  run,
  swing,
  ready,
  hitConfirm,
  pointWin,
  pointLoss,
}
