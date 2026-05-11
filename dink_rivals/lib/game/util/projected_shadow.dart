import 'package:flutter/material.dart';

import '../config/visual_palette.dart';

class ProjectedShadow {
  const ProjectedShadow._();

  static Offset offset({
    double elevationFraction = 0,
    double scale = 1,
  }) {
    final elevationScale =
        (1 + elevationFraction.clamp(0, 1) * 0.65).toDouble();
    return VisualPalette.shadowScreenOffset *
        scale.clamp(0, double.infinity).toDouble() *
        elevationScale;
  }

  static Rect directionalOvalRect({
    required Offset center,
    required double width,
    required double height,
    double elevationFraction = 0,
    double offsetScale = 1,
  }) {
    return Rect.fromCenter(
      center: center +
          offset(
            elevationFraction: elevationFraction,
            scale: offsetScale,
          ),
      width: width,
      height: height,
    );
  }

  static Paint paint(double opacity) {
    return Paint()
      ..color = VisualPalette.projectedShadow.withValues(
        alpha: opacity.clamp(0, VisualPalette.projectedShadowMaxAlpha),
      );
  }
}
