import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dink_rivals_game.dart';
import '../config/visual_palette.dart';

class RallyFeedbackComponent extends Component {
  RallyFeedbackComponent(this.game);

  final DinkRivalsGame game;
  static const TextStyle _textStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: 'monospace',
  );
  String _lastText = '';
  double _popSeconds = 0;

  @override
  void update(double dt) {
    if (game.feedbackText != _lastText) {
      _lastText = game.feedbackText;
      _popSeconds = game.feedbackText.isEmpty ? 0 : 0.25;
    } else if (_popSeconds > 0) {
      _popSeconds = (_popSeconds - dt).clamp(0, 1).toDouble();
    }
  }

  @override
  void render(Canvas canvas) {
    if (game.feedbackText.isEmpty) {
      return;
    }
    final scale = _popSeconds <= 0 ? 1.0 : 1.0 + 0.2 * (_popSeconds / 0.25);
    final textPainter = TextPainter(
      text: TextSpan(
        text: game.feedbackText,
        style: _textStyle.copyWith(color: colorForFeedback(game.feedbackText)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(game.size.x / 2, game.size.y * 0.22);
    canvas.scale(scale);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @visibleForTesting
  static Color colorForFeedback(String text) {
    final upper = text.toUpperCase();
    if (upper.contains('FAULT')) return VisualPalette.feedbackFault;
    if (upper.contains('SMASH')) return VisualPalette.feedbackSmash;
    if (upper.contains('LOB')) return VisualPalette.feedbackLob;
    if (upper.contains('DRIVE')) return VisualPalette.feedbackDrive;
    if (upper.contains('DINK')) return VisualPalette.feedbackDink;
    return VisualPalette.uiAccent;
  }
}
