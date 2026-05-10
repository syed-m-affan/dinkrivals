import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../dink_rivals_game.dart';
import '../models/player_side.dart';
import '../models/player_state.dart';

class PlayerComponent extends Component {
  PlayerComponent(this.game)
      : state = PlayerState(
          position: Vector2(Court.playerStartX, Court.playerStartY),
          side: PlayerSide.player,
        );

  final DinkRivalsGame game;
  final PlayerState state;
  final Paint _paint = Paint()..color = Colors.blue;

  @override
  void render(Canvas canvas) {
    final center = game.courtToWorld(state.position);
    canvas.drawCircle(center.toOffset(), game.logicalToScreen(10), _paint);
  }
}
