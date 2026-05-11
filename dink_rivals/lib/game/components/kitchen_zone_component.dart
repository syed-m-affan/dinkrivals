import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';

class KitchenZoneComponent extends Component {
  KitchenZoneComponent(this.game);

  final DinkRivalsGame game;
  final Paint _paint = Paint()..color = VisualPalette.kitchenOverlay;

  @override
  void render(Canvas canvas) {
    _drawZone(canvas, Court.opponentKitchenTopY, Court.opponentKitchenBottomY);
    _drawZone(canvas, Court.playerKitchenTopY, Court.playerKitchenBottomY);
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
}
