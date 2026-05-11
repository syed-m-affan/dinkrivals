import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dink_rivals_game.dart';

class DebugOverlayComponent extends Component {
  DebugOverlayComponent(this.game);

  final DinkRivalsGame game;
  final TextPaint _textPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 11,
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
    final text = 'PHASE 0  FPS ${_fps.toStringAsFixed(0)}  '
        'Ball ${ball.x.toStringAsFixed(0)},${ball.y.toStringAsFixed(0)},${ball.z.toStringAsFixed(0)}  '
        'Rally ${game.rallyCount}  Shot $shot';
    // Below the centered score chip (which extends to ~y=38 at the top).
    canvas.drawRect(const Rect.fromLTWH(8, 44, 342, 20), _background);
    _textPaint.render(canvas, text, Vector2(12, 48));
  }
}
