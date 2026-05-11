import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dink_rivals_game.dart';
import '../systems/touch_input_controller.dart';

class TouchControlsComponent extends Component {
  TouchControlsComponent(this.game);

  final DinkRivalsGame game;
  final Paint _strokePaint = Paint()
    ..color = const Color(0xAAFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final Paint _disabledMoveControlPaint = Paint()
    ..color = const Color(0x22303030);
  final Paint _enabledMoveControlPaint = Paint()
    ..color = const Color(0x55303030);
  final Paint _disabledMoveKnobPaint = Paint()..color = const Color(0x554AA3FF);
  final Paint _enabledMoveKnobPaint = Paint()..color = const Color(0xAA4AA3FF);
  final Paint _swingPaint = Paint()..color = const Color(0xAA4FD08B);
  final Paint _swingTrackPaint = Paint()
    ..color = const Color(0x55303030)
    ..style = PaintingStyle.stroke;
  final Paint _serveStroke = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  final Paint _powerRing = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 7
    ..strokeCap = StrokeCap.round;

  final TextPainter _swingText = TextPainter(
    text: const TextSpan(
      text: 'SWING',
      style: TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );
  final TextPainter _serveText = TextPainter(
    text: const TextSpan(
      text: 'SERVE',
      style: TextStyle(
        color: Colors.black,
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

  @override
  void update(double dt) {
    priority = 10000;
  }

  @override
  void render(Canvas canvas) {
    final layout = TouchControlLayout(game.size);
    final waitingToServe = game.isWaitingToServe;
    _renderMoveControl(canvas, layout, waitingToServe);
    _renderSwingControl(canvas, layout);
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
    final knobCenter =
        layout.moveCenter + stickVector * (layout.moveRadius * 0.62);
    canvas.drawCircle(
      layout.moveCenter.toOffset(),
      layout.moveRadius,
      waitingToServe ? _disabledMoveControlPaint : _enabledMoveControlPaint,
    );
    canvas.drawCircle(
      layout.moveCenter.toOffset(),
      layout.moveRadius,
      _strokePaint,
    );
    canvas.drawCircle(
      knobCenter.toOffset(),
      23,
      waitingToServe ? _disabledMoveKnobPaint : _enabledMoveKnobPaint,
    );
    canvas.drawCircle(knobCenter.toOffset(), 23, _strokePaint);
  }

  void _renderSwingControl(Canvas canvas, TouchControlLayout layout) {
    final swingKnobCenter = layout.swingCenter +
        Vector2(
              math.sin(game.inputSystem.racketAngle),
              -math.cos(game.inputSystem.racketAngle),
            ) *
            (layout.swingRadius * 0.62);
    _swingTrackPaint.strokeWidth = layout.swingRadius * 0.62;
    canvas.drawArc(
      Rect.fromCircle(
        center: layout.swingCenter.toOffset(),
        radius: layout.swingRadius,
      ),
      math.pi,
      -math.pi,
      false,
      _swingTrackPaint,
    );
    canvas.drawCircle(
      layout.swingCenter.toOffset(),
      layout.swingRadius,
      _strokePaint,
    );
    canvas.drawCircle(swingKnobCenter.toOffset(), 19, _swingPaint);
    canvas.drawCircle(swingKnobCenter.toOffset(), 19, _strokePaint);

    _swingText.layout(maxWidth: layout.swingRadius * 2);
    _swingText.paint(
      canvas,
      Offset(
        layout.swingCenter.x - _swingText.width / 2,
        layout.swingCenter.y - layout.swingRadius - 22,
      ),
    );
  }

  void _renderServeButton(Canvas canvas, TouchControlLayout layout) {
    final charge = game.serveChargeFraction;
    final serveFill = Paint()
      ..color = Color.lerp(
        const Color(0xCCFFCB47),
        const Color(0xFFFF8C2E),
        charge,
      )!;

    canvas.drawCircle(
      layout.serveCenter.toOffset(),
      layout.serveRadius,
      serveFill,
    );
    canvas.drawCircle(
      layout.serveCenter.toOffset(),
      layout.serveRadius,
      _serveStroke,
    );
    if (charge > 0) {
      canvas.drawArc(
        Rect.fromCircle(
          center: layout.serveCenter.toOffset(),
          radius: layout.serveRadius + 10,
        ),
        -math.pi / 2,
        math.pi * 2 * charge,
        false,
        _powerRing,
      );
    }

    _serveText.layout(maxWidth: layout.serveRadius * 2);
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
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    _powerText.layout(maxWidth: layout.serveRadius * 2.8);
    _powerText.paint(
      canvas,
      Offset(
        layout.serveCenter.x - _powerText.width / 2,
        layout.serveCenter.y + layout.serveRadius + 14,
      ),
    );
  }
}
