import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';

class RallyStripComponent extends Component {
  RallyStripComponent(this.game);

  final DinkRivalsGame game;

  static const TextStyle _lineStyle = TextStyle(
    color: VisualPalette.hudReadoutText,
    fontSize: 13,
    fontWeight: FontWeight.bold,
    fontFamily: 'monospace',
    letterSpacing: 0,
    shadows: [
      Shadow(
        color: VisualPalette.scoreboardShadow,
        offset: Offset(1.5, 1.5),
      ),
    ],
  );
  final TextStyle _lastShotStyle =
      _lineStyle.copyWith(color: VisualPalette.hudLastShotLabel);
  late TextPainter _rallyPainter = _painter('', _lineStyle);
  late TextPainter _lastShotPainter = _painter('', _lastShotStyle);
  String _lastRallyText = '';
  String _lastShotText = '';

  @override
  void render(Canvas canvas) {
    final left = math.max(10.0, game.size.x * 0.035);
    final top = game.size.y < 760 ? 74.0 : 84.0;
    final rally = _rallyPainterFor(rallyLabelForTesting());
    final last = _lastShotPainterFor(lastShotLabelForTesting());

    rally.paint(canvas, Offset(left, top));
    last.paint(canvas, Offset(left, top + rally.height + 5));
  }

  TextPainter _painter(String text, TextStyle style) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  TextPainter _rallyPainterFor(String text) {
    if (text != _lastRallyText) {
      _lastRallyText = text;
      _rallyPainter = _painter(text, _lineStyle);
    }
    return _rallyPainter;
  }

  TextPainter _lastShotPainterFor(String text) {
    if (text != _lastShotText) {
      _lastShotText = text;
      _lastShotPainter = _painter(text, _lastShotStyle);
    }
    return _lastShotPainter;
  }

  @visibleForTesting
  String rallyLabelForTesting() => 'RALLY: ${game.matchState.rallyCount}';

  @visibleForTesting
  String lastShotLabelForTesting() {
    final shot = game.shotSystem.lastShotType?.name.toUpperCase() ?? '-';
    return 'LAST SHOT: $shot';
  }
}
