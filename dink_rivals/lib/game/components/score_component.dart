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
  final Paint _playerPanel = Paint()..color = VisualPalette.scoreboardPlayer;
  final Paint _opponentPanel = Paint()
    ..color = VisualPalette.scoreboardOpponent;
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
  late final TextPainter _playerLabelPainter = _painter('YOU', _labelStyle);
  late TextPainter _opponentLabelPainter = _painter('ROOKIE', _labelStyle);
  late TextPainter _playerScorePainter = _painter('00', _textStyle);
  late TextPainter _opponentScorePainter = _painter('00', _textStyle);
  int? _lastPlayerScore;
  int? _lastOpponentScore;
  String? _lastOpponentLabel;

  @override
  void render(Canvas canvas) {
    final match = game.matchState;
    final opponentLabel = opponentLabelForTesting();
    if (_lastOpponentLabel != opponentLabel) {
      _lastOpponentLabel = opponentLabel;
      _opponentLabelPainter = _painter(opponentLabel, _labelStyle);
    }
    final panelWidth = game.size.x < 390 ? 58.0 : 62.0;
    final panelHeight = 54.0;
    const gap = 2.0;
    final left = math.max(10.0, game.size.x * 0.035);
    final top = 8.0;
    final playerRect = Rect.fromLTWH(left, top, panelWidth, panelHeight);
    final opponentRect = Rect.fromLTWH(
      left + panelWidth + gap,
      top,
      panelWidth,
      panelHeight,
    );

    _drawScorePanel(
      canvas,
      playerRect,
      _playerLabelPainter,
      _scorePainterForPlayer(match.playerScore),
      _playerPanel,
    );
    _drawScorePanel(
      canvas,
      opponentRect,
      _opponentLabelPainter,
      _scorePainterForOpponent(match.opponentScore),
      _opponentPanel,
    );
    final activeRect =
        match.servingSide == PlayerSide.player ? playerRect : opponentRect;
    canvas.drawRRect(
      RRect.fromRectAndRadius(activeRect, const Radius.circular(6)),
      _activeBorder,
    );
    final indicatorX = activeRect.center.dx;
    canvas.drawCircle(
      Offset(indicatorX, activeRect.top + 13),
      game.logicalToScreen(2.4).clamp(2.2, 3.2),
      _serveIndicator,
    );
  }

  void _drawScorePanel(
    Canvas canvas,
    Rect rect,
    TextPainter labelPainter,
    TextPainter scorePainter,
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
    labelPainter.paint(
      canvas,
      Offset(rect.center.dx - labelPainter.width / 2, rect.top + 4),
    );
    scorePainter.paint(
      canvas,
      Offset(
        rect.center.dx - scorePainter.width / 2,
        rect.bottom - scorePainter.height - 3,
      ),
    );
  }

  TextPainter _painter(String text, TextStyle style) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  TextPainter _scorePainterForPlayer(int score) {
    if (score != _lastPlayerScore) {
      _lastPlayerScore = score;
      _playerScorePainter = _painter(_scoreText(score), _textStyle);
    }
    return _playerScorePainter;
  }

  TextPainter _scorePainterForOpponent(int score) {
    if (score != _lastOpponentScore) {
      _lastOpponentScore = score;
      _opponentScorePainter = _painter(_scoreText(score), _textStyle);
    }
    return _opponentScorePainter;
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
  String opponentLabelForTesting() {
    final name = game.opponentVisual.displayName.toUpperCase();
    return name == 'RALLY QUEEN' ? 'RALLY' : name;
  }
}
