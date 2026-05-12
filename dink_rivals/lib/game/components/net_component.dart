import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';

/// Foreground net rail aligned to the painted bg image.
///
/// The background contains the full court and net mesh art. This component
/// only redraws a thin projected rail/post overlay at `Court.netY`, giving
/// far-side balls and characters a visual occluder without creating a second
/// net that fights the painted court.
class NetComponent extends Component {
  NetComponent(this.game) {
    priority = Court.netY.round();
  }

  final DinkRivalsGame game;

  static const double _topZ = 86;

  @override
  void render(Canvas canvas) {
    final leftGround = game.courtToWorld(Vector2(Court.left, Court.netY));
    final rightGround = game.courtToWorld(Vector2(Court.right, Court.netY));
    final leftTop = game.courtToWorld(Vector2(Court.left, Court.netY), _topZ);
    final rightTop = game.courtToWorld(Vector2(Court.right, Court.netY), _topZ);

    final depthScale = game.depthScaleForY(Court.netY);
    final railWidth = _scaledStroke(1.0, depthScale, min: 2.0, max: 4.0);
    final postWidth = _scaledStroke(1.15, depthScale, min: 2.4, max: 4.4);

    _drawPosts(canvas, leftGround, rightGround, leftTop, rightTop, postWidth);
    _drawRail(canvas, leftTop, rightTop, railWidth);
  }

  void _drawPosts(
    Canvas canvas,
    Vector2 leftGround,
    Vector2 rightGround,
    Vector2 leftTop,
    Vector2 rightTop,
    double postWidth,
  ) {
    final postPaint = Paint()
      ..color = VisualPalette.netPost
      ..strokeWidth = postWidth
      ..strokeCap = StrokeCap.round;
    final highlightPaint = Paint()
      ..color = VisualPalette.netPostHighlight
      ..strokeWidth = postWidth * 0.34
      ..strokeCap = StrokeCap.round;

    for (final pair in [
      (leftGround, leftTop),
      (rightGround, rightTop),
    ]) {
      canvas.drawLine(pair.$1.toOffset(), pair.$2.toOffset(), postPaint);
      canvas.drawLine(
        pair.$1.toOffset() + Offset(-postWidth * 0.16, 0),
        pair.$2.toOffset() + Offset(-postWidth * 0.16, 0),
        highlightPaint,
      );
    }
  }

  void _drawRail(
    Canvas canvas,
    Vector2 leftTop,
    Vector2 rightTop,
    double railWidth,
  ) {
    final shadowPaint = Paint()
      ..color = VisualPalette.netRailShadow
      ..strokeWidth = railWidth * 1.35
      ..strokeCap = StrokeCap.round;
    final railPaint = Paint()
      ..color = VisualPalette.netRail.withValues(alpha: 0.55)
      ..strokeWidth = railWidth
      ..strokeCap = StrokeCap.round;
    final highlightPaint = Paint()
      ..color = VisualPalette.netRailHighlight.withValues(alpha: 0.38)
      ..strokeWidth = railWidth * 0.34
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(leftTop.toOffset(), rightTop.toOffset(), shadowPaint);
    canvas.drawLine(leftTop.toOffset(), rightTop.toOffset(), railPaint);
    canvas.drawLine(
      leftTop.toOffset() + Offset(0, -railWidth * 0.38),
      rightTop.toOffset() + Offset(0, -railWidth * 0.38),
      highlightPaint,
    );
  }

  double _scaledStroke(
    double baseCourtUnits,
    double depthScale, {
    required double min,
    required double max,
  }) {
    return game
        .logicalToScreen(baseCourtUnits * depthScale)
        .clamp(min, max)
        .toDouble();
  }
}
