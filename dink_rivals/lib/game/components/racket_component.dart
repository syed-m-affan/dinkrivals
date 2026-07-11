import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/tuning_constants.dart';
import '../dink_rivals_game.dart';
import '../config/visual_palette.dart';
import '../models/swing_intent.dart';
import '../systems/shot_system.dart';

class RacketComponent extends Component {
  RacketComponent(this.game);

  final DinkRivalsGame game;
  final Paint _swingLanePaint = Paint()
    ..color = VisualPalette.uiAccent.withValues(alpha: 0.30)
    ..strokeCap = StrokeCap.round;
  final Paint _swingLaneFillPaint = Paint();
  final Paint _swingLaneBorderPaint = Paint()
    ..color = VisualPalette.textPrimary.withValues(alpha: 0.76)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint _aimArrowFillPaint = Paint()
    ..color = VisualPalette.feedbackFault
    ..style = PaintingStyle.fill;
  final Paint _aimArrowHighlightPaint = Paint()
    ..color = VisualPalette.textPrimary.withValues(alpha: 0.86)
    ..style = PaintingStyle.fill;
  final Paint _aimArrowOutlinePaint = Paint()
    ..color = VisualPalette.textInverse.withValues(alpha: 0.92)
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.miter;
  final Paint _aimArrowShadowPaint = Paint()
    ..color = VisualPalette.projectedShadow.withValues(alpha: 0.36)
    ..style = PaintingStyle.fill;
  final Paint _pixelSwipePaint = Paint();

  @override
  void update(double dt) {
    priority = 9000;
  }

  @override
  void render(Canvas canvas) {
    _drawPlayerSwingLane(canvas);
    _drawAimIndicator(canvas);
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
    final startDepth = game.visualScaleForY(path.start.y);
    final endDepth = game.visualScaleForY(path.end.y);
    final midDepth = (startDepth + endDepth) / 2;
    final laneColor = _laneColorFor(command.intent);
    _swingLanePaint.color = laneColor.withValues(alpha: 0.34);
    _swingLaneBorderPaint.color = VisualPalette.textPrimary.withValues(
      alpha: command.intent == SwingIntent.smash ? 0.88 : 0.72,
    );
    final startRadius =
        game.logicalToScreen(Tuning.committedSwingContactRadius * startDepth);
    final endRadius =
        game.logicalToScreen(Tuning.committedSwingContactRadius * endDepth);

    // Draw the lane fill as a tapered quad so its half-width matches the
    // depth scale at each end. drawLine cannot taper, so use a polygon.
    final delta = end - start;
    final length = delta.length;
    if (length > 0.01) {
      final perp = Vector2(-delta.y, delta.x).normalized();
      final p0 = start + perp * startRadius;
      final p1 = end + perp * endRadius;
      final p2 = end - perp * endRadius;
      final p3 = start - perp * startRadius;
      final fillPath = Path()
        ..moveTo(p0.x, p0.y)
        ..lineTo(p1.x, p1.y)
        ..lineTo(p2.x, p2.y)
        ..lineTo(p3.x, p3.y)
        ..close();
      _swingLaneFillPaint.color = _swingLanePaint.color;
      canvas.drawPath(fillPath, _swingLaneFillPaint);
    }

    _swingLaneBorderPaint.strokeWidth = game.logicalToScreen(2.2 * midDepth);
    canvas.drawLine(start.toOffset(), end.toOffset(), _swingLaneBorderPaint);
    canvas.drawCircle(start.toOffset(), startRadius, _swingLaneBorderPaint);
    canvas.drawCircle(end.toOffset(), endRadius, _swingLaneBorderPaint);
    _drawPixelSwipe(canvas, start.toOffset(), end.toOffset(), midDepth);
  }

  Color _laneColorFor(SwingIntent intent) {
    return switch (intent) {
      SwingIntent.dink => VisualPalette.feedbackDink,
      SwingIntent.drive => VisualPalette.feedbackDrive,
      SwingIntent.lob => VisualPalette.feedbackLob,
      SwingIntent.smash => VisualPalette.feedbackSmash,
    };
  }

  @visibleForTesting
  Color aimIndicatorColorForTesting() => game.selectedPaddleSkin.aimColor;

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
    for (var i = 0; i < blocks; i += 1) {
      final t = blocks == 1 ? 1.0 : i / (blocks - 1);
      final center = Offset.lerp(start, end, t)!;
      final size = blockSize * (0.55 + t * 0.65);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: size, height: size),
        _pixelSwipePaint
          ..color =
              VisualPalette.textPrimary.withValues(alpha: 0.32 + t * 0.48),
      );
      canvas.restore();
    }
  }

  void _drawAimIndicator(Canvas canvas) {
    final player = game.player.state.position;
    final markerCourtPosition = game.playerRacketPosition();
    final start = game.courtToWorld(player, Tuning.racketContactZ);
    final marker =
        game.courtToWorld(markerCourtPosition, Tuning.racketContactZ);
    final screenDirection = marker - start;
    if (screenDirection.length < 1) {
      return;
    }
    final depthScale = game.visualScaleForY(player.y);
    final size = game.logicalToScreen(8.5 * depthScale).clamp(7.0, 14.0);
    final angle =
        math.atan2(screenDirection.y, screenDirection.x) + math.pi / 2;
    _aimArrowFillPaint.color = game.selectedPaddleSkin.aimColor;
    _aimArrowOutlinePaint.strokeWidth = (size * 0.16).clamp(1.0, 2.0);

    canvas.save();
    canvas.translate(marker.x, marker.y);
    canvas.rotate(angle);
    final arrow = Path()
      ..moveTo(0, -size)
      ..lineTo(size * 0.74, -size * 0.18)
      ..lineTo(size * 0.30, -size * 0.18)
      ..lineTo(size * 0.30, size * 0.82)
      ..lineTo(-size * 0.30, size * 0.82)
      ..lineTo(-size * 0.30, -size * 0.18)
      ..lineTo(-size * 0.74, -size * 0.18)
      ..close();
    canvas.drawPath(
        arrow.shift(Offset(size * 0.12, size * 0.16)), _aimArrowShadowPaint);
    canvas.drawPath(arrow, _aimArrowFillPaint);
    canvas.drawPath(arrow, _aimArrowOutlinePaint);
    canvas.drawRect(
      Rect.fromLTWH(-size * 0.14, -size * 0.58, size * 0.28, size * 0.62),
      _aimArrowHighlightPaint,
    );
    canvas.restore();
  }
}
