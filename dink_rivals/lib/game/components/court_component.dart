import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../dink_rivals_game.dart';

/// Minimal graybox court guide. Gameplay coordinates still use the same
/// projection as the painted environment, but rendering is reduced to boundary
/// lines so perspective and play-space issues are visible without art noise.
class CourtComponent extends Component {
  CourtComponent(this.game);

  static const String surfaceTextureAsset =
      'court/court_surface_texture_generated.png';

  final DinkRivalsGame game;
  final Paint _outerLinePaint = Paint()
    ..color = const Color(0xFFE3E3E3)
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;
  final Paint _innerLinePaint = Paint()
    ..color = const Color(0xB8E3E3E3)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint _debugKitchenFillPaint = Paint()
    ..color = const Color(0x336BD8E9)
    ..style = PaintingStyle.fill;
  final Paint _debugKitchenEdgePaint = Paint()
    ..color = const Color(0x6687F2FF)
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;
  final Paint _centerMarkPaint = Paint()
    ..color = const Color(0x80FFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void render(Canvas canvas) {
    _outerLinePaint.strokeWidth = game.logicalToScreen(0.9).clamp(1.2, 2.2);
    _innerLinePaint.strokeWidth = game.logicalToScreen(0.65).clamp(0.9, 1.8);
    _debugKitchenEdgePaint.strokeWidth =
        game.logicalToScreen(0.5).clamp(0.8, 1.5);
    _centerMarkPaint.strokeWidth = game.logicalToScreen(0.45).clamp(0.8, 1.4);

    final topLeft = game.courtToWorld(Vector2(Court.left, Court.top));
    final topRight = game.courtToWorld(Vector2(Court.right, Court.top));
    final bottomRight = game.courtToWorld(Vector2(Court.right, Court.bottom));
    final bottomLeft = game.courtToWorld(Vector2(Court.left, Court.bottom));

    final boundary = Path()
      ..moveTo(topLeft.x, topLeft.y)
      ..lineTo(topRight.x, topRight.y)
      ..lineTo(bottomRight.x, bottomRight.y)
      ..lineTo(bottomLeft.x, bottomLeft.y)
      ..close();
    canvas.drawPath(boundary, _outerLinePaint);

    if (game.freeRallyDebugMode) {
      _drawKitchenHighlight(
        canvas,
        topY: Court.opponentKitchenTopY,
        bottomY: Court.opponentKitchenBottomY,
      );
      _drawKitchenHighlight(
        canvas,
        topY: Court.playerKitchenTopY,
        bottomY: Court.playerKitchenBottomY,
      );
    }

    _drawCourtLine(
      canvas,
      Vector2(Court.left, Court.opponentKitchenTopY),
      Vector2(Court.right, Court.opponentKitchenTopY),
      _innerLinePaint,
    );
    _drawCourtLine(
      canvas,
      Vector2(Court.left, Court.playerKitchenBottomY),
      Vector2(Court.right, Court.playerKitchenBottomY),
      _innerLinePaint,
    );
    _drawCourtLine(
      canvas,
      Vector2(Court.width / 2, Court.top),
      Vector2(Court.width / 2, Court.opponentKitchenTopY),
      _innerLinePaint,
    );
    _drawCourtLine(
      canvas,
      Vector2(Court.width / 2, Court.playerKitchenBottomY),
      Vector2(Court.width / 2, Court.bottom),
      _innerLinePaint,
    );

    _drawCourtLine(
      canvas,
      Vector2(Court.width / 2 - 6, Court.netY),
      Vector2(Court.width / 2 + 6, Court.netY),
      _centerMarkPaint,
    );
  }

  void _drawCourtLine(Canvas canvas, Vector2 a, Vector2 b, Paint paint) {
    final start = game.courtToWorld(a);
    final end = game.courtToWorld(b);
    canvas.drawLine(start.toOffset(), end.toOffset(), paint);
  }

  void _drawKitchenHighlight(
    Canvas canvas, {
    required double topY,
    required double bottomY,
  }) {
    final topLeft = game.courtToWorld(Vector2(Court.left, topY));
    final topRight = game.courtToWorld(Vector2(Court.right, topY));
    final bottomRight = game.courtToWorld(Vector2(Court.right, bottomY));
    final bottomLeft = game.courtToWorld(Vector2(Court.left, bottomY));
    final path = Path()
      ..moveTo(topLeft.x, topLeft.y)
      ..lineTo(topRight.x, topRight.y)
      ..lineTo(bottomRight.x, bottomRight.y)
      ..lineTo(bottomLeft.x, bottomLeft.y)
      ..close();
    canvas
      ..drawPath(path, _debugKitchenFillPaint)
      ..drawPath(path, _debugKitchenEdgePaint);
  }
}
