import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/debug_flags.dart';
import '../config/tuning_constants.dart';
import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';

class RacketComponent extends Component {
  RacketComponent(this.game);

  final DinkRivalsGame game;
  final Paint _playerPaint = Paint()
    ..color = VisualPalette.playerPaddle
    ..strokeCap = StrokeCap.round;
  final Paint _opponentPaint = Paint()
    ..color = VisualPalette.opponentPaddle
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
