import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';

/// Foreground net rail aligned to the painted bg image.
///
/// The background contains the full court and net mesh art. This component
/// redraws only a subtle rail at `Court.netY`, giving far-side balls and
/// characters a visual occluder without creating a second net that fights the
/// painted court.
class NetComponent extends Component {
  NetComponent(this.game) {
    priority = Court.netY.round();
  }

  final DinkRivalsGame game;

  @override
  void render(Canvas canvas) {
    final left = game.courtToWorld(Vector2(Court.left, Court.netY));
    final right = game.courtToWorld(Vector2(Court.right, Court.netY));
    final depthScale = game.depthScaleForY(Court.netY);
    final railWidth =
        game.logicalToScreen(1.0 * depthScale).clamp(2.0, 4.0).toDouble();

    final shadowPaint = Paint()
      ..color = VisualPalette.netRailShadow.withValues(alpha: 0.55)
      ..strokeWidth = railWidth * 1.35
      ..strokeCap = StrokeCap.round;
    final railPaint = Paint()
      ..color = VisualPalette.netRail.withValues(alpha: 0.48)
      ..strokeWidth = railWidth
      ..strokeCap = StrokeCap.round;
    final highlightPaint = Paint()
      ..color = VisualPalette.netRailHighlight.withValues(alpha: 0.32)
      ..strokeWidth = railWidth * 0.34
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(left.toOffset(), right.toOffset(), shadowPaint);
    canvas.drawLine(left.toOffset(), right.toOffset(), railPaint);
    canvas.drawLine(
      left.toOffset() + Offset(0, -railWidth * 0.38),
      right.toOffset() + Offset(0, -railWidth * 0.38),
      highlightPaint,
    );
  }
}
