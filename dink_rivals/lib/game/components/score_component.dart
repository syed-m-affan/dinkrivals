import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dink_rivals_game.dart';
import '../config/visual_palette.dart';
import '../models/player_side.dart';

class ScoreComponent extends Component {
  ScoreComponent(this.game);

  final DinkRivalsGame game;
  static const TextStyle _textStyle = TextStyle(
    color: VisualPalette.courtLineWhite,
    fontSize: 30,
    fontWeight: FontWeight.bold,
    fontFamily: 'monospace',
  );
  final Paint _background = Paint()..color = VisualPalette.scoreboardSurface;
  final Paint _serveIndicator = Paint()..color = VisualPalette.uiAccent;

  @override
  void render(Canvas canvas) {
    final match = game.matchState;
    final score = scoreLabelForTesting();
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
    final indicatorY = rect.center.dy;
    final indicatorX = match.servingSide == PlayerSide.player
        ? rect.left + 12
        : rect.right - 12;
    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      game.logicalToScreen(2.2),
      _serveIndicator,
    );
    textPainter.paint(
      canvas,
      Offset(game.size.x / 2 - textPainter.width / 2, 15),
    );
  }

  @visibleForTesting
  String scoreLabelForTesting() {
    final match = game.matchState;
    return '${match.playerScore} - ${match.opponentScore}';
  }

  @visibleForTesting
  PlayerSide servingIndicatorSideForTesting() {
    return game.matchState.servingSide;
  }
}
