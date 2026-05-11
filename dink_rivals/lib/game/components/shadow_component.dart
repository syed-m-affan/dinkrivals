import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dink_rivals_game.dart';

class ShadowComponent extends Component {
  ShadowComponent(this.game);

  final DinkRivalsGame game;

  @override
  void update(double dt) {
    priority = game.ball.state.y.round() - 1;
  }

  @override
  void render(Canvas canvas) {
    final ball = game.ball.state;
    final center = game.courtToWorld(Vector2(ball.x, ball.y));
    final heightScale = (ball.z / 120).clamp(0, 1).toDouble();
    final depthScale = game.depthScaleForY(ball.y);
    final width = (13 + heightScale * 11) * depthScale;
    final height = (6 + heightScale * 5) * depthScale;
    final opacity = (0.58 - heightScale * 0.28).clamp(0.26, 0.58).toDouble();
    final rect = Rect.fromCenter(
      center: center.toOffset(),
      width: game.logicalToScreen(width),
      height: game.logicalToScreen(height),
    );
    canvas.drawOval(
        rect, Paint()..color = Colors.black.withValues(alpha: opacity));
  }
}
