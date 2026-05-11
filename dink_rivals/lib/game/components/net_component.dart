import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';

class NetComponent extends Component {
  NetComponent(this.game) {
    priority = Court.netY.round();
  }

  static const double _netHeight = 31;

  final DinkRivalsGame game;
  final Paint _meshFill = Paint()..color = VisualPalette.netMesh;
  final Paint _meshStroke = Paint()
    ..color = VisualPalette.netMeshStroke
    ..style = PaintingStyle.stroke;
  final Paint _meshDiagonalStroke = Paint()
    ..color = VisualPalette.netMeshDiagonal
    ..style = PaintingStyle.stroke;
  final Paint _dropOutline = Paint()
    ..color = VisualPalette.netDropOutline
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;
  final Paint _topCord = Paint()
    ..color = VisualPalette.netRail
    ..style = PaintingStyle.stroke;
  final Paint _topCordHighlight = Paint()
    ..color = VisualPalette.netRailHighlight
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint _topCordShadow = Paint()
    ..color = VisualPalette.netRailShadow
    ..style = PaintingStyle.stroke;
  final Paint _postPaint = Paint()
    ..color = VisualPalette.netPost
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint _postHighlightPaint = Paint()
    ..color = VisualPalette.netPostHighlight
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint _castShadowPaint = Paint()..color = VisualPalette.netCastShadow;

  @override
  void render(Canvas canvas) {
    final groundLeft = game.courtToWorld(Vector2(Court.left, Court.netY));
    final groundRight = game.courtToWorld(Vector2(Court.right, Court.netY));
    final topLeft =
        game.courtToWorld(Vector2(Court.left, Court.netY), _netHeight);
    final topRight =
        game.courtToWorld(Vector2(Court.right, Court.netY), _netHeight);
    final shadowLeft =
        game.courtToWorld(Vector2(Court.left + 5, Court.netY + 10));
    final shadowRight =
        game.courtToWorld(Vector2(Court.right + 5, Court.netY + 10));
    final shadowNearRight =
        game.courtToWorld(Vector2(Court.right + 12, Court.netY + 17));
    final shadowNearLeft =
        game.courtToWorld(Vector2(Court.left + 12, Court.netY + 17));

    _meshStroke.strokeWidth = game.logicalToScreen(0.72);
    _meshDiagonalStroke.strokeWidth = game.logicalToScreen(0.38);
    _dropOutline.strokeWidth = game.logicalToScreen(4.2);
    _topCord.strokeWidth = game.logicalToScreen(3.2);
    _topCordHighlight.strokeWidth = game.logicalToScreen(1.15);
    _topCordShadow.strokeWidth = game.logicalToScreen(4.8);
    _postPaint.strokeWidth = game.logicalToScreen(5.0);
    _postHighlightPaint.strokeWidth = game.logicalToScreen(1.3);

    final shadowPath = Path()
      ..moveTo(shadowLeft.x, shadowLeft.y)
      ..lineTo(shadowRight.x, shadowRight.y)
      ..lineTo(shadowNearRight.x, shadowNearRight.y)
      ..lineTo(shadowNearLeft.x, shadowNearLeft.y)
      ..close();
    canvas.drawPath(shadowPath, _castShadowPaint);

    final meshPath = Path()
      ..moveTo(topLeft.x, topLeft.y)
      ..lineTo(topRight.x, topRight.y)
      ..lineTo(groundRight.x, groundRight.y)
      ..lineTo(groundLeft.x, groundLeft.y)
      ..close();
    canvas.save();
    canvas.translate(0, game.logicalToScreen(1.4));
    canvas.drawPath(meshPath, _dropOutline);
    canvas.restore();
    canvas.drawPath(meshPath, _meshFill);
    canvas.drawPath(meshPath, _meshStroke);
    _drawMeshLines(canvas, topLeft, topRight, groundLeft, groundRight);

    canvas.drawLine(
        groundLeft.toOffset(), groundRight.toOffset(), _topCordShadow);
    canvas.drawLine(
      Offset(topLeft.x, topLeft.y + game.logicalToScreen(1.6)),
      Offset(topRight.x, topRight.y + game.logicalToScreen(1.6)),
      _dropOutline,
    );
    canvas.drawLine(topLeft.toOffset(), topRight.toOffset(), _topCord);
    canvas.drawLine(
      Offset(topLeft.x, topLeft.y - game.logicalToScreen(0.8)),
      Offset(topRight.x, topRight.y - game.logicalToScreen(0.8)),
      _topCordHighlight,
    );
    canvas.drawLine(groundLeft.toOffset(), topLeft.toOffset(), _postPaint);
    canvas.drawLine(groundRight.toOffset(), topRight.toOffset(), _postPaint);
    canvas.drawLine(
      topLeft.toOffset(),
      Vector2(topLeft.x, topLeft.y + game.logicalToScreen(8)).toOffset(),
      _postHighlightPaint,
    );
    canvas.drawLine(
      topRight.toOffset(),
      Vector2(topRight.x, topRight.y + game.logicalToScreen(8)).toOffset(),
      _postHighlightPaint,
    );
  }

  void _drawMeshLines(
    Canvas canvas,
    Vector2 topLeft,
    Vector2 topRight,
    Vector2 groundLeft,
    Vector2 groundRight,
  ) {
    const segments = 10;
    for (var i = 1; i < segments; i++) {
      final t = i / segments;
      final top = topLeft + (topRight - topLeft) * t;
      final bottom = groundLeft + (groundRight - groundLeft) * t;
      canvas.drawLine(top.toOffset(), bottom.toOffset(), _meshStroke);
    }
    for (final i in [1, 6]) {
      final t0 = i / segments;
      final t1 = ((i + 2) / segments).clamp(0.0, 1.0).toDouble();
      final a = topLeft + (topRight - topLeft) * t0;
      final b = groundLeft + (groundRight - groundLeft) * t1;
      canvas.drawLine(a.toOffset(), b.toOffset(), _meshDiagonalStroke);
    }
  }
}
