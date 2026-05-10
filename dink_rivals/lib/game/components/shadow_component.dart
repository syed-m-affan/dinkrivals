import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dink_rivals_game.dart';

class ShadowComponent extends Component {
  ShadowComponent(this.game);

  final DinkRivalsGame game;
  final Paint _paint = Paint()..color = const Color(0x66000000);

  @override
  void render(Canvas canvas) {
    final ball = game.ball.state;
    final center = game.courtToWorld(Vector2(ball.x, ball.y));
    final rect = Rect.fromCenter(
      center: center.toOffset(),
      width: game.logicalToScreen(12),
      height: game.logicalToScreen(6),
    );
    canvas.drawOval(rect, _paint);
  }
}
