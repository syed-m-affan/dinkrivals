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
  final Paint _bodyPaint = Paint()..color = Colors.red;
  final Paint _headPaint = Paint()..color = const Color(0xFFFF7D73);
  final Paint _footPaint = Paint()..color = const Color(0xAA5E0000);

  @override
  void update(double dt) {
    priority = state.position.y.round();
  }

  @override
  void render(Canvas canvas) {
    final depthScale = game.depthScaleForY(state.position.y);
    final feet = game.courtToWorld(state.position);
    final torso = game.courtToWorld(state.position, 16);
    final head = game.courtToWorld(state.position, 28);
    final bodyRadius = game.logicalToScreen(7.4 * depthScale);
    final headRadius = game.logicalToScreen(5.6 * depthScale);
    final footRect = Rect.fromCenter(
      center: feet.toOffset(),
      width: game.logicalToScreen(15 * depthScale),
      height: game.logicalToScreen(6 * depthScale),
    );

    canvas.drawOval(footRect, _footPaint);
    canvas.drawLine(
      feet.toOffset(),
      torso.toOffset(),
      Paint()
        ..color = _bodyPaint.color
        ..strokeWidth = bodyRadius * 1.35
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(torso.toOffset(), bodyRadius, _bodyPaint);
    canvas.drawCircle(head.toOffset(), headRadius, _headPaint);
  }
}
