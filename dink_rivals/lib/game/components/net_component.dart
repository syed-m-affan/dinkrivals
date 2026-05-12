import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/environment_layout.dart';
import '../util/court_projection.dart';
import '../dink_rivals_game.dart';

/// Depth marker for the painted bg image's net line.
///
/// The background contains the full court and net mesh art. This component
/// redraws a tightly aligned crop of that same painted net at `Court.netY`, so
/// far-side characters and balls pass visually under it without introducing
/// mismatched procedural net art.
class NetComponent extends Component {
  NetComponent(this.game) {
    priority = Court.netY.round();
  }

  final DinkRivalsGame game;
  ui.Image? _background;

  static const double _srcTop = CourtProjection.paintedNetY - 32;
  static const double _srcHeight = 76;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _background =
        await game.images.load(EnvironmentLayout.generatedBackgroundAsset);
  }

  @override
  void render(Canvas canvas) {
    final image = _background;
    if (image == null) {
      return;
    }
    final scale = game.courtLayoutSystem.imageScale;
    final offset = game.courtLayoutSystem.imageOffset;
    final src = Rect.fromLTWH(
      0,
      _srcTop,
      image.width.toDouble(),
      _srcHeight,
    );
    final dst = Rect.fromLTWH(
      offset.x,
      offset.y + _srcTop * scale,
      image.width * scale,
      _srcHeight * scale,
    );
    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.none,
    );
  }
}
