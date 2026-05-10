import 'package:flame/components.dart';

class CourtProjection {
  static const double yCompression = 0.65;
  static const double zDisplacement = 0.6;

  static Vector2 courtToScreen(Vector2 courtPos, double z) {
    return Vector2(
      courtPos.x,
      courtPos.y * yCompression - z * zDisplacement,
    );
  }
}
