import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';
import '../models/swing_intent.dart';
import '../systems/touch_input_controller.dart';

class TouchControlsComponent extends Component {
  TouchControlsComponent(this.game);

  final DinkRivalsGame game;
  final Paint _strokePaint = Paint()
    ..color = VisualPalette.controlStroke
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final Paint _controlOuterPaint = Paint()
    ..color = VisualPalette.scoreboardSurface
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5;
  final Paint _disabledMoveControlPaint = Paint()
    ..color = VisualPalette.controlSurfaceDisabled;
  final Paint _enabledMoveControlPaint = Paint()
    ..color = VisualPalette.controlSurface;
  final Paint _disabledMoveKnobPaint = Paint()
    ..color = VisualPalette.controlMoveKnobDisabled;
  final Paint _enabledMoveKnobPaint = Paint()
    ..color = VisualPalette.controlMoveKnob;
  final Paint _swingPaint = Paint()..color = VisualPalette.controlSwingKnob;
  final Paint _swingTrackPaint = Paint()
    ..color = VisualPalette.controlSurface
    ..style = PaintingStyle.stroke;
  final Paint _swingPressedPaint = Paint()
    ..color = VisualPalette.uiAccent.withValues(alpha: 0.4)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final Paint _swingPressedFill = Paint()
    ..color = VisualPalette.uiAccent.withValues(alpha: 0.10);
  final Paint _serveStroke = Paint()
    ..color = VisualPalette.textPrimary
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  final Paint _serveFill = Paint();
  final Paint _powerRing = Paint()
    ..color = VisualPalette.textPrimary
    ..style = PaintingStyle.stroke
    ..strokeWidth = 7
    ..strokeCap = StrokeCap.round;
  final Paint _shotChipPaint = Paint()
    ..color = VisualPalette.scoreboardSurface.withValues(alpha: 0.78);
  final Paint _shotChipActivePaint = Paint()
    ..color = VisualPalette.uiAccent.withValues(alpha: 0.86);
  final Paint _shotChipBorderPaint = Paint()
    ..color = VisualPalette.scoreboardBorder.withValues(alpha: 0.72)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;
  final Paint _moveChevronPaint = Paint()..style = PaintingStyle.fill;
  final Path _moveChevronPath = Path()
    ..moveTo(6, 0)
    ..lineTo(-5, -6)
    ..lineTo(-3, 0)
    ..lineTo(-5, 6)
    ..close();

  final TextPainter _serveText = TextPainter(
    text: const TextSpan(
      text: 'SERVE',
      style: TextStyle(
        color: VisualPalette.textInverse,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  final TextPainter _powerText = TextPainter(
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  final TextPainter _dinkChipText =
      TextPainter(textDirection: TextDirection.ltr);
  final TextPainter _driveChipText =
      TextPainter(textDirection: TextDirection.ltr);
  final TextPainter _verticalChipText =
      TextPainter(textDirection: TextDirection.ltr);
  Rect _dinkChipRect = Rect.zero;
  Rect _driveChipRect = Rect.zero;
  Rect _verticalChipRect = Rect.zero;
  bool _dinkChipActive = false;
  bool _driveChipActive = false;
  bool _verticalChipActive = false;
  SwingIntent? _cachedShotIndicatorActive;
  double _cachedShotIndicatorWidth = -1;
  double _cachedShotIndicatorHeight = -1;
  String _cachedVerticalChipLabel = '';
  double _pulseSeconds = 0;

  @override
  void update(double dt) {
    priority = 10000;
    _pulseSeconds += dt;
  }

  @override
  void render(Canvas canvas) {
    final layout = TouchControlLayout(game.size);
    final waitingToServe = game.isWaitingToServe;
    _renderMoveControl(canvas, layout, waitingToServe);
    _renderSwingControl(canvas, layout);
    _renderShotIndicators(canvas, layout);
    if (waitingToServe) {
      _renderServeButton(canvas, layout);
    }
  }

  void _renderMoveControl(
    Canvas canvas,
    TouchControlLayout layout,
    bool waitingToServe,
  ) {
    final stickVector = waitingToServe
        ? Vector2.zero()
        : Vector2(game.inputSystem.movementX, game.inputSystem.movementY);
    if (stickVector.length > 1) {
      stickVector.normalize();
    }
    final visualRadius = layout.moveVisualRadius;
    final knobCenter = layout.moveCenter + stickVector * (visualRadius * 0.62);
    canvas.drawCircle(
      layout.moveCenter.toOffset(),
      visualRadius,
      waitingToServe ? _disabledMoveControlPaint : _enabledMoveControlPaint,
    );
    canvas.drawCircle(
      layout.moveCenter.toOffset(),
      visualRadius + 4,
      _controlOuterPaint,
    );
    canvas.drawCircle(
      layout.moveCenter.toOffset(),
      visualRadius,
      _strokePaint,
    );
    canvas.drawCircle(
      knobCenter.toOffset(),
      19,
      waitingToServe ? _disabledMoveKnobPaint : _enabledMoveKnobPaint,
    );
    canvas.drawCircle(knobCenter.toOffset(), 19, _strokePaint);
    _drawMoveChevrons(canvas, layout, waitingToServe);
  }

  void _drawMoveChevrons(
    Canvas canvas,
    TouchControlLayout layout,
    bool waitingToServe,
  ) {
    _moveChevronPaint.color = waitingToServe
        ? VisualPalette.controlStroke.withValues(alpha: 0.36)
        : VisualPalette.controlStroke;
    final center = layout.moveCenter;
    final radius = layout.moveVisualRadius * 0.72;
    _drawMoveChevron(canvas, center, 0, -radius, -math.pi / 2);
    _drawMoveChevron(canvas, center, 0, radius, math.pi / 2);
    _drawMoveChevron(canvas, center, -radius, 0, math.pi);
    _drawMoveChevron(canvas, center, radius, 0, 0);
  }

  void _drawMoveChevron(
    Canvas canvas,
    Vector2 center,
    double dx,
    double dy,
    double angle,
  ) {
    canvas.save();
    canvas.translate(center.x + dx, center.y + dy);
    canvas.rotate(angle);
    canvas.drawPath(_moveChevronPath, _moveChevronPaint);
    canvas.restore();
  }

  void _renderSwingControl(Canvas canvas, TouchControlLayout layout) {
    final pressed = game.touchInputController.swingPointerId != null;
    final pulse = pressed ? (math.sin(_pulseSeconds * 12) + 1) * 0.5 : 0.0;
    final baseRadius = layout.swingVisualRadius;
    final visualRadius = baseRadius + (pressed ? 4 + pulse * 2 : 0);
    final swingKnobCenter = layout.swingCenter +
        Vector2(
              math.sin(game.inputSystem.racketAngle),
              -math.cos(game.inputSystem.racketAngle),
            ) *
            (baseRadius * 0.62);
    _swingTrackPaint.strokeWidth = baseRadius * 0.58;
    canvas.drawArc(
      Rect.fromCircle(
        center: layout.swingCenter.toOffset(),
        radius: visualRadius,
      ),
      math.pi,
      -math.pi,
      false,
      _swingTrackPaint,
    );
    if (pressed) {
      _swingPressedPaint.strokeWidth = 5 + pulse * 2;
      canvas.drawCircle(
        layout.swingCenter.toOffset(),
        visualRadius + 12 + pulse * 2,
        _swingPressedFill,
      );
      canvas.drawArc(
        Rect.fromCircle(
          center: layout.swingCenter.toOffset(),
          radius: visualRadius + 8,
        ),
        math.pi,
        -math.pi,
        false,
        _swingPressedPaint,
      );
    }
    canvas.drawCircle(
      layout.swingCenter.toOffset(),
      visualRadius + 4,
      _controlOuterPaint,
    );
    canvas.drawCircle(
      layout.swingCenter.toOffset(),
      visualRadius,
      _strokePaint,
    );
    final knobRadius = pressed ? 21.0 + pulse * 1.5 : 18.0;
    canvas.drawCircle(swingKnobCenter.toOffset(), knobRadius, _swingPaint);
    canvas.drawCircle(swingKnobCenter.toOffset(), knobRadius, _strokePaint);
  }

  void _renderShotIndicators(Canvas canvas, TouchControlLayout layout) {
    final active = game.inputSystem.activeSwingCommand?.intent;
    _ensureShotIndicatorLayout(layout, active);
    _paintShotChip(canvas, _dinkChipText, _dinkChipRect, _dinkChipActive);
    _paintShotChip(canvas, _driveChipText, _driveChipRect, _driveChipActive);
    _paintShotChip(
        canvas, _verticalChipText, _verticalChipRect, _verticalChipActive);
  }

  void _paintShotChip(
    Canvas canvas,
    TextPainter painter,
    Rect rect,
    bool isActive,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      isActive ? _shotChipActivePaint : _shotChipPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      _shotChipBorderPaint,
    );
    painter.paint(
      canvas,
      Offset(
        rect.center.dx - painter.width / 2,
        rect.center.dy - painter.height / 2,
      ),
    );
  }

  void _ensureShotIndicatorLayout(
    TouchControlLayout layout,
    SwingIntent? active,
  ) {
    final verticalLabel = switch (active) {
      SwingIntent.lob => 'LOB',
      SwingIntent.smash => 'SMASH',
      _ => 'LOB/SMASH',
    };
    if (_cachedShotIndicatorActive == active &&
        _cachedShotIndicatorWidth == layout.size.x &&
        _cachedShotIndicatorHeight == layout.size.y &&
        _cachedVerticalChipLabel == verticalLabel) {
      return;
    }
    _cachedShotIndicatorActive = active;
    _cachedShotIndicatorWidth = layout.size.x;
    _cachedShotIndicatorHeight = layout.size.y;
    _cachedVerticalChipLabel = verticalLabel;

    const horizontalMargin = 8.0;
    final y = layout.swingCenter.y - layout.swingVisualRadius - 70;
    final centerX = layout.swingCenter.x;
    _dinkChipActive = false;
    _driveChipActive = active == SwingIntent.drive;
    _verticalChipActive =
        active == SwingIntent.lob || active == SwingIntent.smash;
    _configureChip(_dinkChipText, 'DINK', _dinkChipActive);
    _configureChip(_driveChipText, 'DRIVE', _driveChipActive);
    _configureChip(_verticalChipText, verticalLabel, _verticalChipActive);
    _dinkChipRect = Rect.fromCenter(
      center: Offset(centerX - 60, y),
      width: _dinkChipText.width + 14,
      height: 22,
    );
    _driveChipRect = Rect.fromCenter(
      center: Offset(centerX, y),
      width: _driveChipText.width + 14,
      height: 22,
    );
    _verticalChipRect = Rect.fromCenter(
      center: Offset(centerX + 68, y),
      width: _verticalChipText.width + 14,
      height: 22,
    );

    final minLeft = math.min(
      _dinkChipRect.left,
      math.min(_driveChipRect.left, _verticalChipRect.left),
    );
    final maxRight = math.max(
      _dinkChipRect.right,
      math.max(_driveChipRect.right, _verticalChipRect.right),
    );
    final rightLimit = layout.size.x - horizontalMargin;
    final shiftRight = math.max(0, horizontalMargin - minLeft).toDouble();
    final shiftLeft =
        math.min(0, rightLimit - (maxRight + shiftRight)).toDouble();
    final shift = shiftRight + shiftLeft;
    if (shift == 0) {
      return;
    }
    final offset = Offset(shift, 0);
    _dinkChipRect = _dinkChipRect.shift(offset);
    _driveChipRect = _driveChipRect.shift(offset);
    _verticalChipRect = _verticalChipRect.shift(offset);
  }

  void _configureChip(TextPainter painter, String label, bool isActive) {
    painter.text = TextSpan(
      text: label,
      style: TextStyle(
        color: isActive ? VisualPalette.textInverse : VisualPalette.textPrimary,
        fontSize: label.length > 6 ? 9 : 10,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
    painter.layout();
  }

  static List<({TextPainter painter, Rect rect, bool isActive})>
      _shotIndicatorLayout(
    TouchControlLayout layout,
    SwingIntent? active,
  ) {
    const horizontalMargin = 8.0;
    final y = layout.swingCenter.y - layout.swingVisualRadius - 70;
    final centerX = layout.swingCenter.x;
    final verticalLabel = switch (active) {
      SwingIntent.lob => 'LOB',
      SwingIntent.smash => 'SMASH',
      _ => 'LOB/SMASH',
    };
    final items = <({String label, SwingIntent? intent, double dx})>[
      (label: 'DINK', intent: null, dx: -60),
      (label: 'DRIVE', intent: SwingIntent.drive, dx: 0),
      (label: verticalLabel, intent: SwingIntent.lob, dx: 68),
    ];
    final chips = items.map((item) {
      final isActive = active != null &&
          (active == item.intent ||
              (item.intent == SwingIntent.lob && active == SwingIntent.smash));
      final painter = TextPainter(
        text: TextSpan(
          text: item.label,
          style: TextStyle(
            color: isActive
                ? VisualPalette.textInverse
                : VisualPalette.textPrimary,
            fontSize: item.label.length > 6 ? 9 : 10,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      return (
        painter: painter,
        rect: Rect.fromCenter(
          center: Offset(centerX + item.dx, y),
          width: painter.width + 14,
          height: 22,
        ),
        isActive: isActive,
      );
    }).toList();

    final minLeft =
        chips.map((chip) => chip.rect.left).reduce(math.min).toDouble();
    final maxRight =
        chips.map((chip) => chip.rect.right).reduce(math.max).toDouble();
    final rightLimit = layout.size.x - horizontalMargin;
    final shiftRight = math.max(0, horizontalMargin - minLeft).toDouble();
    final shiftLeft =
        math.min(0, rightLimit - (maxRight + shiftRight)).toDouble();
    final shift = shiftRight + shiftLeft;
    if (shift == 0) {
      return chips;
    }
    return chips
        .map(
          (chip) => (
            painter: chip.painter,
            rect: chip.rect.shift(Offset(shift, 0)),
            isActive: chip.isActive,
          ),
        )
        .toList();
  }

  @visibleForTesting
  static List<Rect> shotIndicatorRectsForTesting({
    required Vector2 size,
    SwingIntent? active,
  }) {
    return _shotIndicatorLayout(TouchControlLayout(size), active)
        .map((chip) => chip.rect)
        .toList();
  }

  void _renderServeButton(Canvas canvas, TouchControlLayout layout) {
    final charge = game.serveChargeFraction;
    final visualRadius = layout.serveVisualRadius;
    _serveFill.color = Color.lerp(
      VisualPalette.uiAccent.withValues(alpha: 0.8),
      VisualPalette.servePowerEnd,
      charge,
    )!;

    canvas.drawCircle(
      layout.serveCenter.toOffset(),
      visualRadius,
      _serveFill,
    );
    canvas.drawCircle(
      layout.serveCenter.toOffset(),
      visualRadius,
      _serveStroke,
    );
    if (charge > 0) {
      canvas.drawArc(
        Rect.fromCircle(
          center: layout.serveCenter.toOffset(),
          radius: visualRadius + 9,
        ),
        -math.pi / 2,
        math.pi * 2 * charge,
        false,
        _powerRing,
      );
    }

    _serveText.layout(maxWidth: visualRadius * 2);
    _serveText.paint(
      canvas,
      Offset(
        layout.serveCenter.x - _serveText.width / 2,
        layout.serveCenter.y - _serveText.height / 2,
      ),
    );

    _powerText.text = TextSpan(
      text: game.isServeCharging
          ? '${math.max(1, (charge * 100).round())}%'
          : 'HOLD',
      style: const TextStyle(
        color: VisualPalette.textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    _powerText.layout(maxWidth: visualRadius * 2.8);
    _powerText.paint(
      canvas,
      Offset(
        layout.serveCenter.x - _powerText.width / 2,
        layout.serveCenter.y + visualRadius + 13,
      ),
    );
  }
}
