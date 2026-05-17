import 'dart:math' as math;

import 'package:flame/components.dart';

import '../util/court_projection.dart';

/// Maps the painted `CourtProjection` image-space guide onto actual screen
/// pixels using the same transform as the environment background.
class CourtLayoutSystem {
  double _imageScale = 1;
  Vector2 _imageOffset = Vector2.zero();

  double get courtScale => _imageScale;

  void resize(Vector2 size) {
    final scale = math.max(
      size.x / CourtProjection.imageWidth,
      size.y / CourtProjection.imageHeight,
    );
    _imageScale = scale;
    _imageOffset = Vector2(
      (size.x - CourtProjection.imageWidth * scale) / 2,
      (size.y - CourtProjection.imageHeight * scale) / 2,
    );
  }

  /// Cover-fit transform exposed so future environment renderers can pull it
  /// from one source of truth.
  double get imageScale => _imageScale;
  Vector2 get imageOffset => Vector2(_imageOffset.x, _imageOffset.y);

  Vector2 courtToWorld(Vector2 courtPosition, [double z = 0]) {
    final imagePoint = CourtProjection.courtToScreen(courtPosition, z);
    return Vector2(
      _imageOffset.x + imagePoint.x * _imageScale,
      _imageOffset.y + imagePoint.y * _imageScale,
    );
  }

  /// Convert a logical court-unit length into screen pixels at the near
  /// baseline. Used by stroke widths and sprite sizing.
  double logicalToScreen(double logicalUnits) {
    // 1 court-unit of width at the near baseline equals
    //   (paintedNearRightX - paintedNearLeftX) / Court.width  image px,
    // which is `imageScale` * that ratio screen px.
    const nearWidthImage =
        CourtProjection.paintedNearRightX - CourtProjection.paintedNearLeftX;
    const unitsToImagePx = nearWidthImage / _courtWidthUnits;
    return logicalUnits * unitsToImagePx * _imageScale;
  }

  double depthScaleForY(double courtY) =>
      CourtProjection.depthScaleForY(courtY);

  double visualScaleForY(double courtY) =>
      CourtProjection.visualScaleForY(courtY);

  // Constant kept local so the import does not pull court_constants.dart in
  // here; ensure this stays in sync with `Court.width`.
  static const double _courtWidthUnits = 220.0;
}
