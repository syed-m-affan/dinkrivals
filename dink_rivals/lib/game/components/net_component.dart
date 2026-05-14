import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../dink_rivals_game.dart';

/// Projected net sorted at the net plane.
class NetComponent extends Component {
  NetComponent(this.game) {
    priority = Court.netY.round();
  }

  final DinkRivalsGame game;
  final Paint _meshFillPaint = Paint()
    ..color = const Color(0x33202020)
    ..style = PaintingStyle.fill;
  final Paint _meshPaint = Paint()
    ..color = const Color(0x66202020)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint _tapePaint = Paint()
    ..color = const Color(0xDD202020)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint _postPaint = Paint()
    ..color = const Color(0xCC202020)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void render(Canvas canvas) {
    _meshPaint.strokeWidth = game.logicalToScreen(0.45).clamp(0.7, 1.3);
    _tapePaint.strokeWidth = game.logicalToScreen(1.25).clamp(2.0, 3.4);
    _postPaint.strokeWidth = game.logicalToScreen(1.0).clamp(1.4, 2.6);

    final bottomLeft = game.courtToWorld(Vector2(Court.left, Court.netY));
    final bottomRight = game.courtToWorld(Vector2(Court.right, Court.netY));
    final topLeft =
        game.courtToWorld(Vector2(Court.left, Court.netY), Court.netHeight);
    final topRight =
        game.courtToWorld(Vector2(Court.right, Court.netY), Court.netHeight);
    final postTopLeft =
        game.courtToWorld(Vector2(Court.left, Court.netY), Court.netPostHeight);
    final postTopRight = game.courtToWorld(
      Vector2(Court.right, Court.netY),
      Court.netPostHeight,
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

    canvas.drawLine(topLeft.toOffset(), topRight.toOffset(), _tapePaint);
  }
}
