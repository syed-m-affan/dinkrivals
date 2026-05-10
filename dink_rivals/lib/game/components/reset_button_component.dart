import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../dink_rivals_game.dart';

class ResetButtonComponent extends PositionComponent with TapCallbacks {
  ResetButtonComponent(this.game);

  final DinkRivalsGame game;
  final Paint _background = Paint()..color = const Color(0xCC202020);
  final TextPaint _textPaint = TextPaint(
    style: const TextStyle(color: Colors.white, fontSize: 12),
  );

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = Vector2(112, 36);
    position = Vector2(size.x - this.size.x - 10, 10);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(6)),
      _background,
    );
    _textPaint.render(canvas, 'RESET POINT', Vector2(17, 10));
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.resetPoint();
  }
}
