import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/debug_flags.dart';
import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';
import '../models/ball_state.dart';

class BallComponent extends Component {
  BallComponent(this.game)
      : state = BallState(
          x: Court.ballServeX,
          y: Court.ballServeY,
          z: 0,
        );

  final DinkRivalsGame game;
  final BallState state;
  final Paint _paint = Paint()..color = VisualPalette.ballPrimary;
  ui.Image? _ballSprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (!DebugFlags.useSprites) {
      return;
    }
    _ballSprite = await game.images.load('sprites/ball.png');
  }

  @override
  void update(double dt) {
    priority = state.y.round();
  }

  @override
  void render(Canvas canvas) {
    final center = game.courtToWorld(Vector2(state.x, state.y), state.z);
    final depthScale = game.depthScaleForY(state.y);
    final radius = visualRadiusFor(state.z, depthScale);
    if (DebugFlags.useSprites && _ballSprite != null) {
      final screenRadius = game.logicalToScreen(radius);
      final dst = Rect.fromCircle(
        center: center.toOffset(),
        radius: screenRadius,
      );
      canvas.drawImageRect(
        _ballSprite!,
        Rect.fromLTWH(
          0,
          0,
          _ballSprite!.width.toDouble(),
          _ballSprite!.height.toDouble(),
        ),
        dst,
        Paint()..filterQuality = FilterQuality.none,
      );
      return;
    }
    canvas.drawCircle(center.toOffset(), game.logicalToScreen(radius), _paint);
  }

  @visibleForTesting
  static double visualRadiusFor(double z, double depthScale) {
    final heightScale = (z / 100).clamp(0, 1).toDouble();
    return (4.2 + heightScale * 4.0) * depthScale;
  }
}
