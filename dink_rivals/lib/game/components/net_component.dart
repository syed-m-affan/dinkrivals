import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';

/// Projected net sorted at the net plane.
class NetComponent extends Component {
  NetComponent(this.game) {
    priority = Court.netY.round();
  }

  static const double _paintedNetHeightScale = 1.85;
  static const double _paintedPostHeightScale = 1.9;

  final DinkRivalsGame game;
  final Paint _meshFillPaint = Paint()
    ..color = VisualPalette.netMesh.withValues(alpha: 0.26)
    ..style = PaintingStyle.fill;
  final Paint _meshPaint = Paint()
    ..color = VisualPalette.netMeshStroke.withValues(alpha: 0.72)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint _tapePaint = Paint()
    ..color = VisualPalette.netRail
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint _postPaint = Paint()
    ..color = VisualPalette.netPost
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint _railShadowPaint = Paint()
    ..color = VisualPalette.netRailShadow.withValues(alpha: 0.66)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void render(Canvas canvas) {
    _meshPaint.strokeWidth = game.logicalToScreen(0.45).clamp(0.7, 1.3);
    _tapePaint.strokeWidth = game.logicalToScreen(1.25).clamp(2.0, 3.4);
    _postPaint.strokeWidth = game.logicalToScreen(1.0).clamp(1.4, 2.6);
    _railShadowPaint.strokeWidth = _tapePaint.strokeWidth;

    final bottomLeft = game.courtToWorld(Vector2(Court.left, Court.netY));
    final bottomRight = game.courtToWorld(Vector2(Court.right, Court.netY));
    final topLeft = game.courtToWorld(
      Vector2(Court.left, Court.netY),
      Court.netHeight * _paintedNetHeightScale,
    );
    final topRight = game.courtToWorld(
      Vector2(Court.right, Court.netY),
      Court.netHeight * _paintedNetHeightScale,
    );
    final postTopLeft = game.courtToWorld(
      Vector2(Court.left, Court.netY),
      Court.netPostHeight * _paintedPostHeightScale,
    );
    final postTopRight = game.courtToWorld(
      Vector2(Court.right, Court.netY),
      Court.netPostHeight * _paintedPostHeightScale,
    );

    canvas.drawLine(
      bottomLeft.toOffset(),
      postTopLeft.toOffset(),
      _postPaint,
    );
    canvas.drawLine(
      bottomRight.toOffset(),
      postTopRight.toOffset(),
      _postPaint,
    );

    final meshPath = Path()
      ..moveTo(bottomLeft.x, bottomLeft.y)
      ..lineTo(bottomRight.x, bottomRight.y)
      ..lineTo(topRight.x, topRight.y)
      ..lineTo(topLeft.x, topLeft.y)
      ..close();
    canvas.drawPath(meshPath, _meshFillPaint);

    for (var i = 0; i <= 10; i++) {
      final t = i / 10;
      final bottom = bottomLeft + (bottomRight - bottomLeft) * t;
      final top = topLeft + (topRight - topLeft) * t;
      canvas.drawLine(bottom.toOffset(), top.toOffset(), _meshPaint);
    }
    for (var i = 1; i <= 2; i++) {
      final t = i / 3;
      final left = bottomLeft + (topLeft - bottomLeft) * t;
      final right = bottomRight + (topRight - bottomRight) * t;
      canvas.drawLine(left.toOffset(), right.toOffset(), _meshPaint);
    }

    final railShadowOffset = Offset(0, game.logicalToScreen(0.7));
    canvas.drawLine(
      topLeft.toOffset() + railShadowOffset,
      topRight.toOffset() + railShadowOffset,
      _railShadowPaint,
    );
    canvas.drawLine(topLeft.toOffset(), topRight.toOffset(), _tapePaint);
  }
}
