import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../dink_rivals_game.dart';

class NetComponent extends Component {
  NetComponent(this.game);

  final DinkRivalsGame game;
  final Paint _paint = Paint()
    ..color = Colors.black87
    ..strokeWidth = 4;

  @override
  void render(Canvas canvas) {
    final start = game.courtToWorld(Vector2(Court.left, Court.netY));
    final end = game.courtToWorld(Vector2(Court.right, Court.netY));
    canvas.drawLine(start.toOffset(), end.toOffset(), _paint);
  }
}
