import 'dart:math' as math;

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
  static const TextStyle _labelStyle = TextStyle(
    color: VisualPalette.courtLineWhite,
    fontSize: 10,
    fontWeight: FontWeight.bold,
    fontFamily: 'monospace',
    letterSpacing: 0,
  );
  static const TextStyle _readoutStyle = TextStyle(
    color: VisualPalette.hudReadoutText,
    fontSize: 13,
    fontWeight: FontWeight.bold,
    fontFamily: 'monospace',
    letterSpacing: 0,
  );
  final Paint _playerPanel = Paint()..color = VisualPalette.scoreboardPlayer;
  final Paint _opponentPanel = Paint()
    ..color = VisualPalette.scoreboardOpponent;
  final Paint _divider = Paint()..color = VisualPalette.scoreboardSurface;
  final Paint _border = Paint()
    ..color = VisualPalette.scoreboardBorder
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final Paint _activeBorder = Paint()
    ..color = VisualPalette.uiAccent
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  final Paint _serveIndicator = Paint()..color = VisualPalette.uiAccent;
  final Paint _shadowPaint = Paint()..color = VisualPalette.scoreboardShadow;

  @override
  void render(Canvas canvas) {
    final match = game.matchState;
    final panelWidth = game.size.x < 390 ? 62.0 : 66.0;
    final panelHeight = 58.0;
    final gap = game.size.x < 390 ? 14.0 : 18.0;
    final totalWidth = panelWidth * 2 + gap;
    final left = game.size.x / 2 - totalWidth / 2;
    final top = 8.0;
    final playerRect = Rect.fromLTWH(left, top, panelWidth, panelHeight);
    final opponentRect = Rect.fromLTWH(
      left + panelWidth + gap,
      top,
      panelWidth,
      panelHeight,
    );
    final centerRect = Rect.fromLTWH(left + panelWidth, top + 15, gap, 28);

    _drawScorePanel(canvas, playerRect, 'YOU', match.playerScore, _playerPanel);
    _drawScorePanel(
        canvas, opponentRect, 'RIVAL', match.opponentScore, _opponentPanel);
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, const Radius.circular(4)),
      _divider,
    );
    final activeRect =
        match.servingSide == PlayerSide.player ? playerRect : opponentRect;
    canvas.drawRRect(
      RRect.fromRectAndRadius(activeRect, const Radius.circular(6)),
      _activeBorder,
    );
    final labelPainter =
        _painter(match.matchOver ? 'OVER' : 'SERVE', _labelStyle);
    labelPainter.paint(
      canvas,
      Offset(
        centerRect.center.dx - labelPainter.width / 2,
        centerRect.center.dy - labelPainter.height / 2,
      ),
    );
    final indicatorX = activeRect.center.dx;
    canvas.drawCircle(
      Offset(indicatorX, activeRect.top + 13),
      game.logicalToScreen(2.4).clamp(2.2, 3.2),
      _serveIndicator,
    );
    _drawReadouts(canvas);
  }

  void _drawScorePanel(
    Canvas canvas,
    Rect rect,
    String label,
    int score,
    Paint fill,
  ) {
    final shadowRect = rect.translate(0, 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, const Radius.circular(6)),
      _shadowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      _border,
    );
    final labelPainter = _painter(label, _labelStyle);
    labelPainter.paint(
      canvas,
      Offset(rect.center.dx - labelPainter.width / 2, rect.top + 4),
    );
    final scorePainter = _painter(_scoreText(score), _textStyle);
    scorePainter.paint(
      canvas,
      Offset(
        rect.center.dx - scorePainter.width / 2,
        rect.bottom - scorePainter.height - 3,
      ),
    );
  }

  void _drawReadouts(Canvas canvas) {
    final left = math.max(10.0, game.size.x * 0.04);
    final top = game.size.y < 760 ? 74.0 : 84.0;
    final rally = _painter(rallyLabelForTesting(), _readoutStyle);
    final last = _painter(
        lastShotLabelForTesting(),
        _readoutStyle.copyWith(
          color: VisualPalette.hudLastShotLabel,
        ));
    rally.paint(canvas, Offset(left, top));
    last.paint(canvas, Offset(left, top + rally.height + 5));
  }

  TextPainter _painter(String text, TextStyle style) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  String _scoreText(int score) => score.toString().padLeft(2, '0');

  @visibleForTesting
  String scoreLabelForTesting() {
    final match = game.matchState;
    return '${match.playerScore} - ${match.opponentScore}';
  }

  @visibleForTesting
  PlayerSide servingIndicatorSideForTesting() {
    return game.matchState.servingSide;
  }

  @visibleForTesting
  String rallyLabelForTesting() => 'RALLY: ${game.rallyCount}';

  @visibleForTesting
  String lastShotLabelForTesting() {
    final shot = game.shotSystem.lastShotType?.name.toUpperCase() ?? '-';
    return 'LAST SHOT: $shot';
  }
}
