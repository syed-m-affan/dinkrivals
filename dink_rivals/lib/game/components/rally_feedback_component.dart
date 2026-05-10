import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dink_rivals_game.dart';

class RallyFeedbackComponent extends Component {
  RallyFeedbackComponent(this.game);

  final DinkRivalsGame game;
  static const TextStyle _textStyle = TextStyle(
    color: Color(0xFFFFE36A),
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: 'monospace',
  );

  @override
  void render(Canvas canvas) {
    if (game.feedbackText.isEmpty) {
      return;
    }
    final textPainter = TextPainter(
      text: TextSpan(text: game.feedbackText, style: _textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        game.size.x / 2 - textPainter.width / 2,
        game.size.y * 0.22,
      ),
    );
  }
}
