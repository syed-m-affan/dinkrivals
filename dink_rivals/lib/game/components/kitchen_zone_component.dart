import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';

class KitchenZoneComponent extends Component {
  KitchenZoneComponent(this.game);

  final DinkRivalsGame game;
  final Paint _paint = Paint()..color = VisualPalette.courtKitchenTint;
  final Paint _edgePaint = Paint()
    ..color = VisualPalette.kitchenEdge
    ..strokeCap = StrokeCap.square;

  @override
  void render(Canvas canvas) {
    _drawZone(canvas, Court.opponentKitchenTopY, Court.opponentKitchenBottomY);
    _drawZone(canvas, Court.playerKitchenTopY, Court.playerKitchenBottomY);
    _drawKitchenEdge(canvas, Court.opponentKitchenTopY + 1.4);
    _drawKitchenEdge(canvas, Court.playerKitchenBottomY - 1.4);
  }

  void _drawZone(Canvas canvas, double topY, double bottomY) {
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
    canvas.drawPath(path, _paint);
  }

  void _drawKitchenEdge(Canvas canvas, double y) {
    final start = game.courtToWorld(Vector2(Court.left, y));
    final end = game.courtToWorld(Vector2(Court.right, y));
    _edgePaint.strokeWidth = game.logicalToScreen(0.5).clamp(1.0, 1.2);
    canvas.drawLine(start.toOffset(), end.toOffset(), _edgePaint);
  }
}
