import 'package:flame/components.dart';

import '../config/court_constants.dart';

/// Projects logical court coordinates into the *painted* court inside the
/// classic park background image (`park_background_overhaul.png`). All four
/// logical court corners map to the four painted court corners, so any line,
/// player, ball, or shadow rendered with `courtToWorld` lands exactly on the
/// pre-rendered pickleball floor in the background.
///
/// This file defines the projection in image-pixel space; `CourtLayoutSystem`
/// applies the same cover-fit transform that the background renderer uses so
/// the projection lands on actual screen pixels.
class CourtProjection {
  // Background image intrinsics. If `park_background_overhaul.png` is
  // regenerated, re-measure these.
  static const double imageWidth = 979.0;
  static const double imageHeight = 1606.0;

  // Pixel coordinates of the four painted court corners inside the bg image.
  // Trapezoid is symmetric around the image's horizontal center.
  static const double paintedFarY = 605.0;
  static const double paintedNearY = 1175.0;
  static const double paintedFarLeftX = 340.0;
  static const double paintedFarRightX = 639.0;
  static const double paintedNearLeftX = 115.0;
  static const double paintedNearRightX = 864.0;

  // Pixels of vertical lift per court z-unit at the near baseline. Z lift at
  // any other y scales linearly with widthAtY so the lift sells perspective.
  static const double _zLiftAtNear = 1.40;
  static const double _minDepthScale = 0.40;
  static const double _maxDepthScale = 1.15;

  static double _t(double courtY) {
    return (courtY / Court.length).clamp(0.0, 1.0).toDouble();
  }

  static double _imageYForCourtY(double courtY) {
    final t = (courtY / Court.length).toDouble();
    return paintedFarY + t * (paintedNearY - paintedFarY);
  }

  static double _imageWidthAtCourtY(double courtY) {
    final t = _t(courtY);
    final farWidth = paintedFarRightX - paintedFarLeftX;
    final nearWidth = paintedNearRightX - paintedNearLeftX;
    return farWidth + t * (nearWidth - farWidth);
  }

  static double _imageCenterX() {
    return (paintedFarLeftX + paintedFarRightX) / 2;
  }

  /// True painted-court width at a court y, in image pixels. Used by
  /// `depthScaleForY` and `zLiftForY` so they cannot drift from the painted
  /// trapezoid.
  static double widthForY(double courtY) => _imageWidthAtCourtY(courtY);

  /// Image-space y for a given court y (no z).
  static double imageYForY(double courtY) => _imageYForCourtY(courtY);

  /// Scale at which the court is being rendered at this y, relative to the
  /// near baseline (1.0 at the player's baseline, smaller toward the rival).
  static double depthScaleForY(double courtY) {
    final nearWidth = paintedNearRightX - paintedNearLeftX;
    final raw = _imageWidthAtCourtY(courtY) / nearWidth;
    return raw.clamp(_minDepthScale, _maxDepthScale).toDouble();
  }

  /// Pixels (image space) of vertical lift per court z-unit at this y. Scales
  /// with the trapezoid so a ball at z=100 lifts more near the camera.
  static double zLiftForY(double courtY) {
    final nearWidth = paintedNearRightX - paintedNearLeftX;
    final widthScale = _imageWidthAtCourtY(courtY) / nearWidth;
    return _zLiftAtNear * widthScale;
  }

  /// Convenience exposed for QA / debugging — not used by renderers.
  static double distanceForY(double courtY) {
    final nearWidth = paintedNearRightX - paintedNearLeftX;
    return nearWidth / _imageWidthAtCourtY(courtY);
  }

  /// Project logical court coordinates to *image-space* pixels. The
  /// `CourtLayoutSystem` translates these into screen pixels using the same
  /// cover-fit transform applied to the bg image.
  static Vector2 courtToScreen(Vector2 courtPos, double z) {
    final widthAtY = _imageWidthAtCourtY(courtPos.y);
    final centerX = _imageCenterX();
    final tx = (courtPos.x - Court.width / 2) / Court.width;
    final imageX = centerX + tx * widthAtY;
    final imageY = _imageYForCourtY(courtPos.y) - z * zLiftForY(courtPos.y);
    return Vector2(imageX, imageY);
  }
}
