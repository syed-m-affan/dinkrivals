import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/debug_flags.dart';
import '../config/tuning_constants.dart';
import '../dink_rivals_game.dart';
import '../config/visual_palette.dart';
import '../models/swing_intent.dart';
import '../systems/shot_system.dart';

class RacketComponent extends Component {
  RacketComponent(this.game);

  final DinkRivalsGame game;
  final Paint _playerPaint = Paint()
    ..color = VisualPalette.playerPaddle
    ..strokeCap = StrokeCap.round;
  final Paint _opponentPaint = Paint()
    ..color = VisualPalette.opponentPaddle
    ..strokeCap = StrokeCap.round;
  final Paint _swingLanePaint = Paint()
    ..color = VisualPalette.uiAccent.withValues(alpha: 0.30)
    ..strokeCap = StrokeCap.round;
  final Paint _swingLaneBorderPaint = Paint()
    ..color = VisualPalette.textPrimary.withValues(alpha: 0.76)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  ui.Image? _playerPaddle;
  ui.Image? _opponentPaddle;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (!DebugFlags.useSprites) {
      return;
    }
    _playerPaddle = await game.images.load('sprites/paddle_player.png');
    _opponentPaddle = await game.images.load('sprites/paddle_opponent.png');
  }

  @override
  void update(double dt) {
    priority = 9000;
  }

  @override
  void render(Canvas canvas) {
    _drawPlayerSwingLane(canvas);
    _drawRacket(
      canvas,
      game.player.state.position,
      game.playerRacketPosition(),
      _playerPaint,
      _playerPaddle,
    );
    _drawRacket(
      canvas,
      game.opponent.state.position,
      game.opponentRacketPosition(),
      _opponentPaint,
      _opponentPaddle,
    );
  }

  void _drawPlayerSwingLane(Canvas canvas) {
    final command = game.inputSystem.activeSwingCommand;
    if (command == null) {
      return;
    }
    final path = ShotSystem.committedSwingPath(
      hitter: game.player.state,
      intent: command.intent,
      swipeDirection: command.swipeDirection,
    );
    final start = game.courtToWorld(path.start, Tuning.racketContactZ);
    final end = game.courtToWorld(path.end, Tuning.racketContactZ);
    final depthScale = game.depthScaleForY(game.player.state.position.y);
    final laneColor = _laneColorFor(command.intent);
    _swingLanePaint.color = laneColor.withValues(alpha: 0.34);
    _swingLaneBorderPaint.color = VisualPalette.textPrimary.withValues(
      alpha: command.intent == SwingIntent.smash ? 0.88 : 0.72,
    );
    _swingLanePaint.strokeWidth =
        game.logicalToScreen(Tuning.committedSwingContactRadius * depthScale);
    _swingLaneBorderPaint.strokeWidth = game.logicalToScreen(2.2 * depthScale);
    canvas.drawLine(start.toOffset(), end.toOffset(), _swingLanePaint);
    canvas.drawLine(start.toOffset(), end.toOffset(), _swingLaneBorderPaint);
    _drawPixelSwipe(canvas, start.toOffset(), end.toOffset(), depthScale);
  }

  Color _laneColorFor(SwingIntent intent) {
    return switch (intent) {
      SwingIntent.dink => VisualPalette.feedbackDink,
      SwingIntent.drive => VisualPalette.feedbackDrive,
      SwingIntent.lob => VisualPalette.feedbackLob,
      SwingIntent.smash => VisualPalette.feedbackSmash,
    };
  }

  void _drawPixelSwipe(
    Canvas canvas,
    Offset start,
    Offset end,
    double depthScale,
  ) {
    final blocks = 7;
    final blockSize = game.logicalToScreen(4.6 * depthScale);
    final delta = end - start;
    final angle = math.atan2(delta.dy, delta.dx);
    final paint = Paint()..color = VisualPalette.textPrimary;
    for (var i = 0; i < blocks; i += 1) {
      final t = blocks == 1 ? 1.0 : i / (blocks - 1);
      final center = Offset.lerp(start, end, t)!;
      final size = blockSize * (0.55 + t * 0.65);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: size, height: size),
        paint
          ..color =
              VisualPalette.textPrimary.withValues(alpha: 0.32 + t * 0.48),
      );
      canvas.restore();
    }
  }

  void _drawRacket(
    Canvas canvas,
    Vector2 courtStart,
    Vector2 courtEnd,
    Paint paint,
    ui.Image? sprite,
  ) {
    final start = game.courtToWorld(courtStart, Tuning.racketContactZ);
    final end = game.courtToWorld(courtEnd, Tuning.racketContactZ);
    final direction = end - start;
    if (direction.length < 1) {
      return;
    }
    final depthScale = game.depthScaleForY(courtStart.y);
    if (DebugFlags.useSprites && sprite != null) {
      final width = game.logicalToScreen(10 * depthScale);
      final height = game.logicalToScreen(18 * depthScale);
      final angle = math.atan2(direction.y, direction.x) + math.pi / 2;
      canvas.save();
      canvas.translate(end.x, end.y);
      canvas.rotate(angle);
      canvas.drawImageRect(
        sprite,
        Rect.fromLTWH(0, 0, sprite.width.toDouble(), sprite.height.toDouble()),
        Rect.fromCenter(
          center: Offset.zero,
          width: width,
          height: height,
        ),
        Paint()..filterQuality = FilterQuality.none,
      );
      canvas.restore();
      return;
    }
    paint.strokeWidth = game.logicalToScreen(2.6 * depthScale);
    canvas.drawLine(start.toOffset(), end.toOffset(), paint);
    canvas.drawCircle(
      end.toOffset(),
      game.logicalToScreen(4.6 * depthScale),
      paint,
    );
  }
}
