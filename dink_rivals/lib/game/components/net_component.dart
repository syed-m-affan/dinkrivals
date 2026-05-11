import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';

class NetComponent extends Component {
  NetComponent(this.game) {
    priority = Court.netY.round();
  }

  static const double _netHeight = 28;

  final DinkRivalsGame game;
  final Paint _meshFill = Paint()..color = VisualPalette.netMesh;
  final Paint _meshStroke = Paint()
    ..color = VisualPalette.netMeshStroke
    ..style = PaintingStyle.stroke;
  final Paint _topCord = Paint()
    ..color = VisualPalette.netRail
    ..style = PaintingStyle.stroke;
  final Paint _postPaint = Paint()
    ..color = VisualPalette.netPost
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void render(Canvas canvas) {
    final groundLeft = game.courtToWorld(Vector2(Court.left, Court.netY));
    final groundRight = game.courtToWorld(Vector2(Court.right, Court.netY));
    final topLeft =
        game.courtToWorld(Vector2(Court.left, Court.netY), _netHeight);
    final topRight =
        game.courtToWorld(Vector2(Court.right, Court.netY), _netHeight);

    _meshStroke.strokeWidth = game.logicalToScreen(0.6);
    _topCord.strokeWidth = game.logicalToScreen(2.2);
    _postPaint.strokeWidth = game.logicalToScreen(3.5);

    final meshPath = Path()
      ..moveTo(topLeft.x, topLeft.y)
      ..lineTo(topRight.x, topRight.y)
      ..lineTo(groundRight.x, groundRight.y)
      ..lineTo(groundLeft.x, groundLeft.y)
      ..close();
    canvas.drawPath(meshPath, _meshFill);
    canvas.drawPath(meshPath, _meshStroke);

    canvas.drawLine(topLeft.toOffset(), topRight.toOffset(), _topCord);
    canvas.drawLine(groundLeft.toOffset(), topLeft.toOffset(), _postPaint);
    canvas.drawLine(groundRight.toOffset(), topRight.toOffset(), _postPaint);
  }
}
