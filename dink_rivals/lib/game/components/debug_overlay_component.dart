import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dink_rivals_game.dart';

class DebugOverlayComponent extends Component {
  DebugOverlayComponent(this.game);

  final DinkRivalsGame game;
  final TextPaint _textPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontFamily: 'monospace',
    ),
  );
  final Paint _background = Paint()..color = const Color(0x80000000);
  double _fps = 0;
  double _accumulator = 0;
  int _frames = 0;

  @override
  void update(double dt) {
    _accumulator += dt;
    _frames++;
    if (_accumulator >= 0.5) {
      _fps = _frames / _accumulator;
      _frames = 0;
      _accumulator = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    final ball = game.ball.state;
    final shot = game.shotSystem.lastShotType?.name ?? '-';
    final text = 'PHASE 0\n'
        'FPS: ${_fps.toStringAsFixed(0)}\n'
        'Ball x: ${ball.x.toStringAsFixed(1)}  '
        'y: ${ball.y.toStringAsFixed(1)}  '
        'z: ${ball.z.toStringAsFixed(1)}\n'
        'Rally: ${game.rallyCount}\n'
        'Last shot: $shot';
    canvas.drawRect(const Rect.fromLTWH(8, 8, 230, 88), _background);
    _textPaint.render(canvas, text, Vector2(14, 12));
  }
}
