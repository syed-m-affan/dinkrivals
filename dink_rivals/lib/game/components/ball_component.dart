import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/debug_flags.dart';
import '../config/tuning_constants.dart';
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
  final Paint _rimPaint = Paint()..color = VisualPalette.ballRim;
  final Paint _accentRimPaint = Paint()..color = VisualPalette.ballAccentRim;
  final Paint _highlightPaint = Paint()..color = VisualPalette.ballHighlight;
  final Paint _dropLinePaint = Paint()
    ..color = VisualPalette.ballPrimary.withValues(alpha: 0.32)
    ..strokeWidth = 1.4
    ..strokeCap = StrokeCap.round;
  final Paint _spritePaint = Paint()..filterQuality = FilterQuality.none;
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
    final screenRadius = game.logicalToScreen(radius);
    if (state.z > 8) {
      // Vertical "drop line" from the ball down to its ground point makes ball
      // altitude readable at a glance — line length encodes z directly.
      final ground = game.courtToWorld(Vector2(state.x, state.y), 0);
      canvas.drawLine(ground.toOffset(), center.toOffset(), _dropLinePaint);
    }
    _drawReadabilityRim(canvas, center, screenRadius);
    if (DebugFlags.useSprites && _ballSprite != null) {
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
        _spritePaint,
      );
      _drawHighlight(canvas, center, screenRadius);
      return;
    }
    canvas.drawCircle(center.toOffset(), screenRadius, _paint);
    _drawHighlight(canvas, center, screenRadius);
  }

  void _drawReadabilityRim(Canvas canvas, Vector2 center, double screenRadius) {
    final outerRadius = screenRadius + 1.8;
    canvas.drawCircle(center.toOffset(), outerRadius, _rimPaint);
    canvas.drawCircle(center.toOffset(), screenRadius + 0.75, _accentRimPaint);
  }

  void _drawHighlight(Canvas canvas, Vector2 center, double screenRadius) {
    final highlightCenter = Offset(
      center.x - screenRadius * 0.32,
      center.y - screenRadius * 0.38,
    );
    canvas.drawCircle(highlightCenter, screenRadius * 0.22, _highlightPaint);
  }

  static double visualRadiusFor(double z, double depthScale) {
    final heightScale = (z / 100).clamp(0, 1).toDouble();
    return (Tuning.ballRadiusBase +
            heightScale * Tuning.ballRadiusAltitudeBoost) *
        depthScale;
  }
}
