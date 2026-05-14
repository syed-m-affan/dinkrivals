import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/debug_flags.dart';
import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';
import '../models/player_side.dart';
import '../models/player_state.dart';
import '../models/shot_type.dart';
import '../util/projected_shadow.dart';

class OpponentComponent extends Component {
  OpponentComponent(this.game)
      : state = PlayerState(
          position: Vector2(Court.opponentStartX, Court.opponentStartY),
          side: PlayerSide.opponent,
        );

  final DinkRivalsGame game;
  final PlayerState state;
  final Paint _bodyPaint = Paint()..color = VisualPalette.opponentPrimary;
  final Paint _headPaint = Paint()..color = VisualPalette.playerSkin;

  ui.Image? _idleSheet;
  ui.Image? _runSheet;
  ui.Image? _swingSheet;
  ui.Image? _dinkSheet;
  ui.Image? _driveSheet;
  ui.Image? _lobSheet;
  ui.Image? _smashSheet;
  ui.Image? _readySheet;
  ui.Image? _hitConfirmSheet;
  double _animationSeconds = 0;
  double _swingSeconds = 0;
  double _hitConfirmSeconds = 0;
  double _pointResultSeconds = 0;
  double _facingX = -1;
  PlayerSide? _pointResultWinner;
  bool _pendingHitConfirm = false;

  static const double _runThreshold = 12;
  static const int _maxSpriteFrames = 12;
  static const int _spriteFrameWidth = 64;
  static const int _spriteFrameHeight = 64;
  static const double _spriteWidth = 37;
  static const double _spriteHeight = 37;
  static const double _spriteFootPadding =
      _spriteHeight * (6 / _spriteFrameHeight);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (!DebugFlags.useSprites) {
      return;
    }
    _idleSheet = await game.images.load('sprites/opponent_idle.png');
    _runSheet = await game.images.load('sprites/opponent_run.png');
    _swingSheet = await game.images.load('sprites/opponent_swing.png');
    _dinkSheet = await game.images.load('sprites/opponent_dink.png');
    _driveSheet = await game.images.load('sprites/opponent_drive.png');
    _lobSheet = await game.images.load('sprites/opponent_lob.png');
    _smashSheet = await game.images.load('sprites/opponent_smash.png');
    _readySheet = await game.images.load('sprites/opponent_ready.png');
    _hitConfirmSheet =
        await game.images.load('sprites/opponent_hit_confirm.png');
  }

  @override
  void update(double dt) {
    priority = state.position.y.round();
    _animationSeconds += dt;
    if (state.velocity.x.abs() > _runThreshold * 0.35 &&
        state.velocity.x.abs() > state.velocity.y.abs() * 0.65) {
      _facingX = state.velocity.x.sign;
    }
    if (state.isSwinging) {
      _animationSeconds = 0;
      _swingSeconds = switch (state.lastShotType) {
        ShotType.dink => 6 / 5,
        ShotType.lob => 6 / 5,
        ShotType.smash => 6 / 6,
        ShotType.drive || ShotType.serve || ShotType.block || null => 6 / 5.5,
      };
      state.isSwinging = false;
    }
    var startedHitConfirm = false;
    if (_swingSeconds > 0) {
      _swingSeconds = (_swingSeconds - dt).clamp(0, 1).toDouble();
      if (_swingSeconds == 0 && _pendingHitConfirm) {
        _hitConfirmSeconds = 0.28;
        _pendingHitConfirm = false;
        startedHitConfirm = true;
      }
    } else if (_pendingHitConfirm) {
      _hitConfirmSeconds = 0.28;
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
      _OpponentPose.idle => _idleSheet,
      _OpponentPose.run => _runSheet,
      _OpponentPose.swing => _swingSheet,
      _OpponentPose.dink => _dinkSheet,
      _OpponentPose.drive => _driveSheet,
      _OpponentPose.lob => _lobSheet,
      _OpponentPose.smash => _smashSheet,
      _OpponentPose.ready => _readySheet,
      _OpponentPose.hitConfirm => _hitConfirmSheet,
      _OpponentPose.pointWin => _readySheet,
      _OpponentPose.pointLoss => _readySheet,
    };
    if (sheet == null) {
      return false;
    }
    final frames = _frameCountFor(sheet);
    final fps = switch (pose) {
      _OpponentPose.idle => 2,
      _OpponentPose.run => _runFpsForSpeed(state.velocity.length),
      _OpponentPose.swing => 5.5,
      _OpponentPose.dink => 5,
      _OpponentPose.drive => 5.5,
      _OpponentPose.lob => 5,
      _OpponentPose.smash => 6,
      _OpponentPose.ready => 3,
      _OpponentPose.hitConfirm => 5,
      _OpponentPose.pointWin => 4,
      _OpponentPose.pointLoss => 3,
    };
    final frame = ((_animationSeconds * fps).floor() % frames).toInt();
    final frameWidth = sheet.width ~/ frames;
    final src = Rect.fromLTWH(
      (frameWidth * frame).toDouble(),
      0,
      frameWidth.toDouble(),
      sheet.height.toDouble(),
    );
    final scale = game.visualScaleForY(state.position.y);
    final feet = game.courtToWorld(state.position);
    final size = Size(
      game.logicalToScreen(_spriteWidth * scale),
      game.logicalToScreen(_spriteHeight * scale),
    );
    final dst = Rect.fromLTWH(
      feet.x - size.width / 2,
      feet.y - size.height + game.logicalToScreen(_spriteFootPadding * scale),
      size.width,
      size.height,
    );
    canvas.save();
    canvas.translate(dst.center.dx, dst.center.dy);
    canvas.scale(_facingX, 1);
    canvas.drawImageRect(
      sheet,
      src,
      Rect.fromCenter(
        center: Offset.zero,
        width: dst.width,
        height: dst.height,
      ),
      Paint()..filterQuality = FilterQuality.none,
    );
    canvas.restore();
    return true;
  }

  _OpponentPose _currentPose() {
    if (_pointResultSeconds > 0) {
      return _pointResultWinner == state.side
          ? _OpponentPose.pointWin
          : _OpponentPose.pointLoss;
    }
    if (_swingSeconds > 0) {
      return _swingPoseForShot(state.lastShotType);
    }
    if (_hitConfirmSeconds > 0) {
      return _OpponentPose.hitConfirm;
    }
    if (state.velocity.length > _runThreshold) {
      return _OpponentPose.run;
    }
    if (!game.matchState.pointInProgress) {
      return _OpponentPose.idle;
    }
    return _OpponentPose.idle;
  }

  _OpponentPose _swingPoseForShot(ShotType? shotType) {
    return switch (shotType) {
      ShotType.dink || ShotType.block => _OpponentPose.dink,
      ShotType.drive || ShotType.serve => _OpponentPose.drive,
      ShotType.lob => _OpponentPose.lob,
      ShotType.smash => _OpponentPose.smash,
      null => _OpponentPose.swing,
    };
  }

  @visibleForTesting
  String currentPoseNameForTesting() => _currentPose().name;

  @visibleForTesting
  static double swingLeanForShotForTesting(ShotType? shotType) {
    return switch (shotType) {
      ShotType.dink || ShotType.block => _OpponentPose.dink,
      ShotType.drive || ShotType.serve => _OpponentPose.drive,
      ShotType.lob => _OpponentPose.lob,
      ShotType.smash => _OpponentPose.smash,
      null => _OpponentPose.swing,
    }
        .index
        .toDouble();
  }

  @visibleForTesting
  int frameCountForTesting(ui.Image sheet) => _frameCountFor(sheet);

  @visibleForTesting
  double facingXForTesting() => _facingX;

  @visibleForTesting
  static double runFpsForSpeedForTesting(double speed) =>
      _runFpsForSpeed(speed);

  static double _runFpsForSpeed(double speed) {
    final t = ((speed - _runThreshold) / 92).clamp(0.0, 1.0).toDouble();
    return 3.6 + t * 4.4;
  }

  int _frameCountFor(ui.Image sheet) {
    return (sheet.width ~/ _spriteFrameWidth).clamp(1, _maxSpriteFrames);
  }

  void showHitConfirm() {
    if (_swingSeconds > 0 || state.isSwinging) {
      _pendingHitConfirm = true;
      return;
    }
    _animationSeconds = 0;
    _hitConfirmSeconds = 0.28;
  }

  void showPointResult(PlayerSide winner) {
    _pendingHitConfirm = false;
    _swingSeconds = 0;
    _hitConfirmSeconds = 0;
    _animationSeconds = 0;
    _pointResultSeconds = 0.72;
    _pointResultWinner = winner;
  }

  void _renderGroundShadow(Canvas canvas) {
    if (!DebugFlags.useProjectedShadows) {
      return;
    }
    final depthScale = game.visualScaleForY(state.position.y);
    final feet = game.courtToWorld(state.position);
    final width = game.logicalToScreen(21 * depthScale);
    final height = game.logicalToScreen(6.2 * depthScale);
    final rect = Rect.fromCenter(
      center:
          feet.toOffset() + Offset(0, game.logicalToScreen(1.4 * depthScale)),
      width: width,
      height: height,
    );
    canvas.drawOval(rect, ProjectedShadow.paint(0.26));
  }

  void _renderPrimitive(Canvas canvas) {
    final depthScale = game.visualScaleForY(state.position.y);
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

  @visibleForTesting
  static double visualScaleFor(double depthScale, double courtY) {
    final nearT = (courtY / Court.length).clamp(0.0, 1.0).toDouble();
    return depthScale * (1.08 + nearT * 0.22);
  }
}

enum _OpponentPose {
  idle,
  run,
  swing,
  dink,
  drive,
  lob,
  smash,
  ready,
  hitConfirm,
  pointWin,
  pointLoss,
}
