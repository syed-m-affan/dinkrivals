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
  final Paint _powerRing = Paint()
    ..color = VisualPalette.textPrimary
    ..style = PaintingStyle.stroke
    ..strokeWidth = 7
    ..strokeCap = StrokeCap.round;
  final Paint _meterEmptyPaint = Paint()..color = VisualPalette.powerMeterEmpty;
  final Paint _meterFillPaint = Paint()..color = VisualPalette.powerMeterFill;
  final Paint _meterHotPaint = Paint()..color = VisualPalette.powerMeterHot;
  final Paint _meterBoltPaint = Paint()..color = VisualPalette.powerMeterBolt;
  final Paint _shotChipPaint = Paint()
    ..color = VisualPalette.scoreboardSurface.withValues(alpha: 0.78);
  final Paint _shotChipActivePaint = Paint()
    ..color = VisualPalette.uiAccent.withValues(alpha: 0.86);
  final Paint _shotChipBorderPaint = Paint()
    ..color = VisualPalette.scoreboardBorder.withValues(alpha: 0.72)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;

  final TextPainter _swingText = TextPainter(
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
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
    final paint = Paint()
      ..color = waitingToServe
          ? VisualPalette.controlStroke.withValues(alpha: 0.36)
          : VisualPalette.controlStroke
      ..style = PaintingStyle.fill;
    final center = layout.moveCenter;
    final radius = layout.moveVisualRadius * 0.72;
    final chevrons = <({double angle, Offset offset})>[
      (angle: -math.pi / 2, offset: Offset(0, -radius)),
      (angle: math.pi / 2, offset: Offset(0, radius)),
      (angle: math.pi, offset: Offset(-radius, 0)),
      (angle: 0, offset: Offset(radius, 0)),
    ];
    for (final chevron in chevrons) {
      canvas.save();
      canvas.translate(
          center.x + chevron.offset.dx, center.y + chevron.offset.dy);
      canvas.rotate(chevron.angle);
      final path = Path()
        ..moveTo(6, 0)
        ..lineTo(-5, -6)
        ..lineTo(-3, 0)
        ..lineTo(-5, 6)
        ..close();
      canvas.drawPath(path, paint);
      canvas.restore();
    }
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
    _drawSwingPowerMeter(canvas, layout, pressed);

    _swingText.text = const TextSpan(
      text: 'AIM',
      style: TextStyle(
        color: VisualPalette.textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    _swingText.layout(maxWidth: layout.swingRadius * 2);
    _swingText.paint(
      canvas,
      Offset(
        layout.swingCenter.x - _swingText.width / 2,
        layout.swingCenter.y - baseRadius - 24,
      ),
    );
  }

  void _renderShotIndicators(Canvas canvas, TouchControlLayout layout) {
    final active = game.inputSystem.activeSwingCommand?.intent;
    final y = layout.swingCenter.y - layout.swingVisualRadius - 70;
    final centerX = layout.swingCenter.x;
    final items = <({String label, SwingIntent? intent, double dx})>[
      (label: 'DINK', intent: null, dx: -60),
      (label: 'DRIVE', intent: SwingIntent.drive, dx: 0),
      (label: 'LOB/SMASH', intent: SwingIntent.lob, dx: 68),
    ];
    for (final item in items) {
      final isActive = active == item.intent ||
          (item.intent == SwingIntent.lob && active == SwingIntent.smash);
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
      final rect = Rect.fromCenter(
        center: Offset(centerX + item.dx, y),
        width: painter.width + 14,
        height: 22,
      );
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
        Offset(rect.center.dx - painter.width / 2,
            rect.center.dy - painter.height / 2),
      );
    }
  }

  void _drawSwingPowerMeter(
    Canvas canvas,
    TouchControlLayout layout,
    bool pressed,
  ) {
    final power = game.isServeCharging
        ? game.serveChargeFraction
        : game.inputSystem.visualSwingPower;
    final meterWidth = 54.0;
    final meterHeight = 10.0;
    final left = layout.swingCenter.x - meterWidth / 2;
    final top = layout.swingCenter.y - layout.swingVisualRadius - 42;
    final rect = Rect.fromLTWH(left, top, meterWidth, meterHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      _meterEmptyPaint,
    );
    const segments = 5;
    final fillSegments = (power * segments).ceil().clamp(0, segments);
    for (var i = 0; i < fillSegments; i += 1) {
      final segmentRect = Rect.fromLTWH(
        left + 4 + i * 9.5,
        top + 2,
        7.0,
        meterHeight - 4,
      );
      canvas.drawRect(
        segmentRect,
        power > 0.76 ? _meterHotPaint : _meterFillPaint,
      );
    }
    final bolt = Path()
      ..moveTo(rect.right + 7, rect.top - 2)
      ..lineTo(rect.right + 1, rect.center.dy + 1)
      ..lineTo(rect.right + 6, rect.center.dy + 1)
      ..lineTo(rect.right + 1, rect.bottom + 5)
      ..lineTo(rect.right + 11, rect.center.dy - 2)
      ..lineTo(rect.right + 6, rect.center.dy - 2)
      ..close();
    canvas.drawPath(bolt, _meterBoltPaint);
    if (pressed && power <= 0.02) {
      canvas.drawCircle(
        Offset(rect.right + 6, rect.center.dy),
        2.2,
        _meterFillPaint,
      );
    }
  }

  void _renderServeButton(Canvas canvas, TouchControlLayout layout) {
    final charge = game.serveChargeFraction;
    final visualRadius = layout.serveVisualRadius;
    final serveFill = Paint()
      ..color = Color.lerp(
        VisualPalette.uiAccent.withValues(alpha: 0.8),
        VisualPalette.servePowerEnd,
        charge,
      )!;

    canvas.drawCircle(
      layout.serveCenter.toOffset(),
      visualRadius,
      serveFill,
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
