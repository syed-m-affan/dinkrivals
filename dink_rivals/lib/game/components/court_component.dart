import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../dink_rivals_game.dart';

class CourtComponent extends Component {
  CourtComponent(this.game);

  final DinkRivalsGame game;
  final Paint _courtPaint = Paint()..color = const Color(0xFFCDBA7A);
  final Paint _linePaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 2;

  @override
  void render(Canvas canvas) {
    final topLeft = game.courtToWorld(Vector2(Court.left, Court.top));
    final topRight = game.courtToWorld(Vector2(Court.right, Court.top));
    final bottomRight = game.courtToWorld(Vector2(Court.right, Court.bottom));
    final bottomLeft = game.courtToWorld(Vector2(Court.left, Court.bottom));

    final path = Path()
      ..moveTo(topLeft.x, topLeft.y)
      ..lineTo(topRight.x, topRight.y)
      ..lineTo(bottomRight.x, bottomRight.y)
      ..lineTo(bottomLeft.x, bottomLeft.y)
      ..close();
    canvas.drawPath(path, _courtPaint);

    _line(canvas, Vector2(Court.left, Court.top), Vector2(Court.right, Court.top));
    _line(canvas, Vector2(Court.left, Court.bottom), Vector2(Court.right, Court.bottom));
    _line(canvas, Vector2(Court.left, Court.top), Vector2(Court.left, Court.bottom));
    _line(canvas, Vector2(Court.right, Court.top), Vector2(Court.right, Court.bottom));
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
  }

  void _line(Canvas canvas, Vector2 a, Vector2 b) {
    final start = game.courtToWorld(a);
    final end = game.courtToWorld(b);
    canvas.drawLine(start.toOffset(), end.toOffset(), _linePaint);
  }
}
