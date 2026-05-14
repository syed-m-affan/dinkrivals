import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../config/environment_layout.dart';
import '../config/visual_palette.dart';
import '../dink_rivals_game.dart';

class ClassicEnvironmentComponent extends Component {
  ClassicEnvironmentComponent(this.game) {
    priority = -1000;
  }

  final DinkRivalsGame game;
  final Paint _fallbackPaint = Paint()..color = VisualPalette.environmentGround;
  ui.Image? _background;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _background = await game.images.load(
      EnvironmentLayout.projectionEnvironmentAsset,
    );
  }

  @override
  void render(Canvas canvas) {
    final background = _background;
    if (background == null) {
      canvas.drawRect(Offset.zero & game.size.toSize(), _fallbackPaint);
      return;
    }

    final imageOffset = game.courtLayoutSystem.imageOffset;
    final imageScale = game.courtLayoutSystem.imageScale;
    final dst = Rect.fromLTWH(
      imageOffset.x,
      imageOffset.y,
      background.width * imageScale,
      background.height * imageScale,
    );
    canvas.drawImageRect(
      background,
      Rect.fromLTWH(
        0,
        0,
        background.width.toDouble(),
        background.height.toDouble(),
      ),
      dst,
      Paint()..filterQuality = FilterQuality.none,
    );
  }
}

class ClassicEnvironmentGeometry {
  const ClassicEnvironmentGeometry._();

  static Size propSize({
    required double imageWidth,
    required double imageHeight,
    required double width,
    required double height,
    required bool preserveAspect,
  }) {
    if (!preserveAspect || imageWidth <= 0 || imageHeight <= 0) {
      return Size(width, height);
    }
    final imageAspect = imageWidth / imageHeight;
    final requestedAspect = width / height;
    if (requestedAspect > imageAspect) {
      return Size(height * imageAspect, height);
    }
    return Size(width, width / imageAspect);
  }

  static Rect propRect({
    required Vector2 anchor,
    required double width,
    required double height,
    required EnvironmentPropAnchor propAnchor,
  }) {
    return switch (propAnchor) {
      EnvironmentPropAnchor.center => Rect.fromCenter(
          center: anchor.toOffset(),
          width: width,
          height: height,
        ),
      EnvironmentPropAnchor.bottomCenter => Rect.fromLTWH(
          anchor.x - width / 2,
          anchor.y - height,
          width,
          height,
        ),
    };
  }
}
