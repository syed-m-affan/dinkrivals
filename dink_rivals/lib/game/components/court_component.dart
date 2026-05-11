import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';

class CourtComponent extends Component {
  CourtComponent(this.game);

  final DinkRivalsGame game;
  final Paint _courtPaint = Paint()..color = VisualPalette.courtSurface;
  final Paint _courtShadePaint = Paint()
    ..color = VisualPalette.courtSurfaceShade;
  final Paint _courtHighlightPaint = Paint()
    ..color = VisualPalette.courtSurfaceHighlight;
  final Paint _linePaint = Paint()
    ..color = VisualPalette.courtLineWhite
    ..strokeCap = StrokeCap.square;
  final Paint _pixelLightPaint = Paint()..color = VisualPalette.courtPixelLight;
  final Paint _pixelDarkPaint = Paint()..color = VisualPalette.courtPixelDark;

  @override
  void render(Canvas canvas) {
    _quad(canvas, Court.top, Court.bottom, _courtPaint);
    _drawServicePanels(canvas);
    _drawPixelTexture(canvas);

    _line(canvas, Vector2(Court.left, Court.top),
        Vector2(Court.right, Court.top));
    _line(canvas, Vector2(Court.left, Court.bottom),
        Vector2(Court.right, Court.bottom));
    _line(canvas, Vector2(Court.left, Court.top),
        Vector2(Court.left, Court.bottom));
    _line(canvas, Vector2(Court.right, Court.top),
        Vector2(Court.right, Court.bottom));
    _line(
      canvas,
      Vector2(Court.left, Court.opponentKitchenTopY),
      Vector2(Court.right, Court.opponentKitchenTopY),
    );
    _line(
      canvas,
      Vector2(Court.left, Court.playerKitchenBottomY),
      Vector2(Court.right, Court.playerKitchenBottomY),
    );
    _line(
      canvas,
      Vector2(Court.width / 2, Court.top),
      Vector2(Court.width / 2, Court.opponentKitchenTopY),
    );
    _line(
      canvas,
      Vector2(Court.width / 2, Court.playerKitchenBottomY),
      Vector2(Court.width / 2, Court.bottom),
    );
  }

  void _drawServicePanels(Canvas canvas) {
    _quadRect(
      canvas,
      Court.left,
      Court.top,
      Court.width / 2,
      Court.opponentKitchenTopY,
      _courtHighlightPaint,
    );
    _quadRect(
      canvas,
      Court.width / 2,
      Court.top,
      Court.right,
      Court.opponentKitchenTopY,
      _courtPaint,
    );
    _quadRect(
      canvas,
      Court.left,
      Court.playerKitchenBottomY,
      Court.width / 2,
      Court.bottom,
      _courtPaint,
    );
    _quadRect(
      canvas,
      Court.width / 2,
      Court.playerKitchenBottomY,
      Court.right,
      Court.bottom,
      _courtHighlightPaint,
    );
    _quadRect(
      canvas,
      Court.left,
      Court.opponentKitchenBottomY,
      Court.right,
      Court.playerKitchenTopY,
      _courtShadePaint,
    );
  }

  void _drawPixelTexture(Canvas canvas) {
    const cell = 20.0;
    const pixel = 4.0;
    for (var y = Court.top + cell; y < Court.bottom - cell; y += cell) {
      for (var x = Court.left + cell; x < Court.right - cell; x += cell) {
        final seed = (x ~/ cell) * 17 + (y ~/ cell) * 31;
        if (seed % 5 != 0) {
          continue;
        }
        final paint = seed.isEven ? _pixelLightPaint : _pixelDarkPaint;
        _quadRect(canvas, x, y, x + pixel, y + pixel, paint);
      }
    }
  }

  void _quad(Canvas canvas, double topY, double bottomY, Paint paint) {
    _quadRect(canvas, Court.left, topY, Court.right, bottomY, paint);
  }

  void _quadRect(
    Canvas canvas,
    double leftX,
    double topY,
    double rightX,
    double bottomY,
    Paint paint,
  ) {
    final topLeft = game.courtToWorld(Vector2(leftX, topY));
    final topRight = game.courtToWorld(Vector2(rightX, topY));
    final bottomRight = game.courtToWorld(Vector2(rightX, bottomY));
    final bottomLeft = game.courtToWorld(Vector2(leftX, bottomY));
    final path = Path()
      ..moveTo(topLeft.x, topLeft.y)
      ..lineTo(topRight.x, topRight.y)
      ..lineTo(bottomRight.x, bottomRight.y)
      ..lineTo(bottomLeft.x, bottomLeft.y)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _line(Canvas canvas, Vector2 a, Vector2 b) {
    final start = game.courtToWorld(a);
    final end = game.courtToWorld(b);
    _linePaint.strokeWidth = game.logicalToScreen(1.15).clamp(1.5, 3.0);
    canvas.drawLine(start.toOffset(), end.toOffset(), _linePaint);
  }
}
