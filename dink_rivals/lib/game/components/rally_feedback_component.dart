import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dink_rivals_game.dart';
import '../config/visual_palette.dart';

class RallyFeedbackComponent extends Component {
  RallyFeedbackComponent(this.game);

  final DinkRivalsGame game;
  static const TextStyle _textStyle = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.bold,
    fontFamily: 'monospace',
  );
  final Paint _panelPaint = Paint()..color = VisualPalette.feedbackBanner;
  final Paint _panelBorderPaint = Paint()
    ..color = VisualPalette.feedbackBannerBorder
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4;
  final Paint _panelShadowPaint = Paint()
    ..color = VisualPalette.scoreboardShadow;
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
    final text = primaryTextFor(game.feedbackText);
    final subtext = secondaryTextFor(game.feedbackText);
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: _textStyle.copyWith(color: colorForFeedback(game.feedbackText)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final subPainter = TextPainter(
      text: TextSpan(
        text: subtext,
        style: const TextStyle(
          color: VisualPalette.feedbackBannerText,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(game.size.x / 2, bannerCenterYForSize(game.size.y));
    canvas.scale(scale);
    final panelWidth = (math.max(textPainter.width, subPainter.width) + 34)
        .clamp(116.0, game.size.x * 0.58)
        .toDouble();
    final panelRect = Rect.fromCenter(
      center: Offset.zero,
      width: panelWidth,
      height: textPainter.height + subPainter.height + 14,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        panelRect.translate(0, 3),
        const Radius.circular(7),
      ),
      _panelShadowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(panelRect, const Radius.circular(6)),
      _panelPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(panelRect, const Radius.circular(6)),
      _panelBorderPaint,
    );
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, panelRect.top + 4),
    );
    subPainter.paint(
      canvas,
      Offset(-subPainter.width / 2, panelRect.top + textPainter.height + 2),
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
    return VisualPalette.feedbackBannerText;
  }

  @visibleForTesting
  static double bannerCenterYForSize(double height) => height < 760 ? 104 : 116;

  @visibleForTesting
  static String primaryTextFor(String text) {
    final upper = text.toUpperCase();
    if (upper.startsWith('FAULT')) {
      return 'FAULT!';
    }
    if (upper.contains('POINT')) {
      return 'POINT!';
    }
    if (upper.contains('SMASH')) return 'SMASH!';
    if (upper.contains('DRIVE')) return 'DRIVE!';
    if (upper.contains('LOB')) return 'LOB!';
    if (upper.contains('DINK')) return 'DINK!';
    return upper.isEmpty ? '' : '$upper!';
  }

  @visibleForTesting
  static String secondaryTextFor(String text) {
    final upper = text.toUpperCase();
    if (upper.startsWith('FAULT')) {
      return upper.replaceFirst('FAULT:', '').trim();
    }
    if (upper.contains('POINT')) {
      return 'RALLY WON';
    }
    if (upper.contains('SMASH')) return 'BIG HIT';
    if (upper.contains('DRIVE')) return 'CLEAN STRIKE';
    if (upper.contains('LOB')) return 'HIGH ARC';
    if (upper.contains('DINK')) return 'NICE SHOT';
    if (upper.contains('MISS')) return 'SWING MISSED';
    return 'NICE SHOT';
  }
}
