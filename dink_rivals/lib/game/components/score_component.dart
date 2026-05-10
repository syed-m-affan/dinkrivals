import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dink_rivals_game.dart';

class ScoreComponent extends Component {
  ScoreComponent(this.game);

  final DinkRivalsGame game;
  static const TextStyle _textStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: 'monospace',
  );
  final Paint _background = Paint()..color = const Color(0x99000000);

  @override
  void render(Canvas canvas) {
    final match = game.matchState;
    final score = '${match.playerScore} - ${match.opponentScore}';
    final label = match.matchOver ? '$score  MATCH OVER' : score;
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: _textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = Rect.fromLTWH(
      game.size.x / 2 - textPainter.width / 2 - 12,
      10,
      textPainter.width + 24,
      textPainter.height + 10,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      _background,
    );
    textPainter.paint(
      canvas,
      Offset(game.size.x / 2 - textPainter.width / 2, 15),
    );
  }
}
