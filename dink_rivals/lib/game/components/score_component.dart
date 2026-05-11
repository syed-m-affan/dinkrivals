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
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: 'monospace',
  );
  static const TextStyle _labelStyle = TextStyle(
    color: VisualPalette.textSoft,
    fontSize: 9,
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

  @override
  void render(Canvas canvas) {
    final match = game.matchState;
    final playerScore = _scoreText(match.playerScore);
    final opponentScore = _scoreText(match.opponentScore);
    final playerPainter = _painter(playerScore, _textStyle);
    final opponentPainter = _painter(opponentScore, _textStyle);
    final labelPainter =
        _painter(match.matchOver ? 'OVER' : 'SERVE', _labelStyle);
    final panelWidth = game.size.x < 390 ? 66.0 : 70.0;
    final panelHeight = 43.0;
    final gap = game.size.x < 390 ? 22.0 : 24.0;
    final totalWidth = panelWidth * 2 + gap;
    final left = game.size.x / 2 - totalWidth / 2;
    final top = 9.0;
    final playerRect = Rect.fromLTWH(left, top, panelWidth, panelHeight);
    final opponentRect = Rect.fromLTWH(
      left + panelWidth + gap,
      top,
      panelWidth,
      panelHeight,
    );
    final centerRect = Rect.fromLTWH(left + panelWidth, top + 8, gap, 28);

    canvas.drawRRect(
      RRect.fromRectAndRadius(playerRect, const Radius.circular(6)),
      _playerPanel,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(opponentRect, const Radius.circular(6)),
      _opponentPanel,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, const Radius.circular(4)),
      _divider,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(playerRect, const Radius.circular(6)),
      _border,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(opponentRect, const Radius.circular(6)),
      _border,
    );
    final activeRect =
        match.servingSide == PlayerSide.player ? playerRect : opponentRect;
    canvas.drawRRect(
      RRect.fromRectAndRadius(activeRect, const Radius.circular(6)),
      _activeBorder,
    );
    playerPainter.paint(
      canvas,
      Offset(
        playerRect.center.dx - playerPainter.width / 2,
        playerRect.center.dy - playerPainter.height / 2 + 2,
      ),
    );
    opponentPainter.paint(
      canvas,
      Offset(
        opponentRect.center.dx - opponentPainter.width / 2,
        opponentRect.center.dy - opponentPainter.height / 2 + 2,
      ),
    );
    labelPainter.paint(
      canvas,
      Offset(
        centerRect.center.dx - labelPainter.width / 2,
        centerRect.center.dy - labelPainter.height / 2,
      ),
    );
    final indicatorX = activeRect.center.dx;
    canvas.drawCircle(
      Offset(indicatorX, activeRect.top + 6),
      game.logicalToScreen(2.0),
      _serveIndicator,
    );
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
}
