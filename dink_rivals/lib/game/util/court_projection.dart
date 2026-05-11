import 'package:flame/components.dart';

import '../config/court_constants.dart';

class CourtProjection {
  static const double yCompression = 0.88;
  static const double farWidthScale = 0.62;
  static const double nearWidthScale = 1.15;
  static const double zDisplacement = 1.25;

  static Vector2 courtToScreen(Vector2 courtPos, double z) {
    final depth = (courtPos.y / Court.length).clamp(0, 1).toDouble();
    final widthScale = farWidthScale + (nearWidthScale - farWidthScale) * depth;
    final centeredX = courtPos.x - Court.width / 2;
    return Vector2(
      Court.width / 2 + centeredX * widthScale,
      courtPos.y * yCompression - z * zDisplacement,
    );
  }

  static double depthScaleForY(double courtY) {
    final depth = (courtY / Court.length).clamp(0, 1).toDouble();
    return 0.78 + depth * 0.34;
  }
}
