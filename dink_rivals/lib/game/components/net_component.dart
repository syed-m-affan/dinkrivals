import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/court_constants.dart';
import '../config/environment_layout.dart';
import '../dink_rivals_game.dart';
import '../util/court_projection.dart';

/// Depth marker for the dedicated painted net layer.
class NetComponent extends Component {
  NetComponent(this.game) {
    priority = Court.netY.round();
  }

  final DinkRivalsGame game;
  ui.Image? _netLayer;

  static const double _srcTop = CourtProjection.paintedNetY - 40;
  static const double _srcHeight = 96;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _netLayer = await game.images.load(EnvironmentLayout.netLayerAsset);
  }

  @override
  void render(Canvas canvas) {
    final image = _netLayer;
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
      Paint()
        ..filterQuality = FilterQuality.none
        ..colorFilter = const ColorFilter.mode(
          Color.fromRGBO(255, 255, 255, 0.68),
          BlendMode.modulate,
        ),
    );
  }
}
