import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../dink_rivals_game.dart';
import '../models/player_side.dart';
import '../models/player_state.dart';

class OpponentComponent extends Component {
  OpponentComponent(this.game)
      : state = PlayerState(
          position: Vector2(Court.opponentStartX, Court.opponentStartY),
          side: PlayerSide.opponent,
        );

  final DinkRivalsGame game;
  final PlayerState state;
  final Paint _paint = Paint()..color = Colors.red;

  @override
  void render(Canvas canvas) {
    final center = game.courtToWorld(state.position);
    canvas.drawCircle(center.toOffset(), game.logicalToScreen(10), _paint);
  }
}
