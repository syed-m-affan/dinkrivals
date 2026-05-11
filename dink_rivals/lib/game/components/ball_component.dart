import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../dink_rivals_game.dart';
import '../models/ball_state.dart';

class BallComponent extends Component {
  BallComponent(this.game)
      : state = BallState(
          x: Court.ballServeX,
          y: Court.ballServeY,
          z: 0,
        );

  final DinkRivalsGame game;
  final BallState state;
  final Paint _paint = Paint()..color = Colors.yellow;

  @override
  void update(double dt) {
    priority = state.y.round();
  }

  @override
  void render(Canvas canvas) {
    final center = game.courtToWorld(Vector2(state.x, state.y), state.z);
    final heightScale = (state.z / 100).clamp(0, 1).toDouble();
    final depthScale = game.depthScaleForY(state.y);
    final radius = (4.2 + heightScale * 4.0) * depthScale;
    canvas.drawCircle(center.toOffset(), game.logicalToScreen(radius), _paint);
  }
}
