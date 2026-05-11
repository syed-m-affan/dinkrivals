import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/tuning_constants.dart';
import '../dink_rivals_game.dart';

class RacketComponent extends Component {
  RacketComponent(this.game);

  final DinkRivalsGame game;
  final Paint _playerPaint = Paint()
    ..color = const Color(0xAA4AA3FF)
    ..strokeCap = StrokeCap.round;
  final Paint _opponentPaint = Paint()
    ..color = const Color(0x99FF5A5A)
    ..strokeCap = StrokeCap.round;

  @override
  void update(double dt) {
    priority = 9000;
  }

  @override
  void render(Canvas canvas) {
    _drawRacket(
      canvas,
      game.player.state.position,
      game.playerRacketPosition(),
      _playerPaint,
    );
    _drawRacket(
      canvas,
      game.opponent.state.position,
      game.opponentRacketPosition(),
      _opponentPaint,
    );
  }

  void _drawRacket(
    Canvas canvas,
    Vector2 courtStart,
    Vector2 courtEnd,
    Paint paint,
  ) {
    final start = game.courtToWorld(courtStart, Tuning.racketContactZ);
    final end = game.courtToWorld(courtEnd, Tuning.racketContactZ);
    final direction = end - start;
    if (direction.length < 1) {
      return;
    }
    final depthScale = game.depthScaleForY(courtStart.y);
    paint.strokeWidth = game.logicalToScreen(2.6 * depthScale);
    canvas.drawLine(start.toOffset(), end.toOffset(), paint);
    canvas.drawCircle(
      end.toOffset(),
      game.logicalToScreen(4.6 * depthScale),
      paint,
    );
  }
}
