import 'dart:math' as math;

import 'package:flame/components.dart';

import '../config/court_constants.dart';

/// Projects logical court coordinates into image-space control points for the
/// current graybox court guide. The logical court corners and net line map to
/// fixed visual control points, so any line, player, ball, or shadow rendered
/// with `courtToWorld` shares the same perspective.
///
/// This file defines the projection in image-pixel space; `CourtLayoutSystem`
/// applies a cover-fit transform so the projection lands on actual screen
/// pixels at any device size. Final environment art should be built to this
/// locked projection once the graybox pass is accepted.
class CourtProjection {
  // Virtual design-space intrinsics for the graybox projection. These are not
  // proof of an accepted painted court background.
  static const double imageWidth = 979.0;
  static const double imageHeight = 1606.0;

  // Image-space control points for the graybox court. These are normalized to
  // the concept screenshot composition, not to the retired generated court
  // bitmap: wide near baseline, moderately compressed far baseline, and a net
  // line above visual center.
  static const double paintedFarY = 430.0;
  static const double paintedNetY = 638.0;
  static const double paintedNearY = 1180.0;
  static const double paintedFarLeftX = 228.0;
  static const double paintedFarRightX = 751.0;
  static const double paintedNearLeftX = 112.0;
  static const double paintedNearRightX = 867.0;
  static const double _perspectiveExponent = 1.85;

  // Pixels of vertical lift per court z-unit at the near baseline. Z lift at
  // any other y scales linearly with widthAtY so the lift sells perspective.
  static const double _zLiftAtNear = 1.40;
  static const double _minDepthScale = 0.40;
  static const double _maxDepthScale = 1.15;

  static double _t(double courtY) {
    return (courtY / Court.length).clamp(0.0, 1.0).toDouble();
  }

  static double _imageYForCourtY(double courtY) {
    final depthT = _depthT(courtY);
    return paintedFarY + depthT * (paintedNearY - paintedFarY);
  }

  static double _imageWidthAtCourtY(double courtY) {
    final t = _depthT(courtY);
    final farWidth = paintedFarRightX - paintedFarLeftX;
    final nearWidth = paintedNearRightX - paintedNearLeftX;
    return farWidth + t * (nearWidth - farWidth);
  }

  static double _depthT(double courtY) {
    return math.pow(_t(courtY), _perspectiveExponent).toDouble();
  }

  static double _imageCenterX() {
    return (paintedFarLeftX + paintedFarRightX) / 2;
  }

  /// True guide width at a court y, in image pixels. Used by `depthScaleForY`
  /// and `zLiftForY` so they cannot drift from the court trapezoid.
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

  /// Visual sprite scale layered on top of projected position. This keeps
  /// collision/world coordinates untouched while making near-court actors read
  /// closer to the concept screenshot.
  static double visualScaleForY(double courtY) {
    final depth = depthScaleForY(courtY);
    final nearT = _t(courtY);
    return depth * (1.08 + nearT * 0.22);
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
  /// `CourtLayoutSystem` translates these into screen pixels using a cover-fit
  /// transform.
  static Vector2 courtToScreen(Vector2 courtPos, double z) {
    final widthAtY = _imageWidthAtCourtY(courtPos.y);
    final centerX = _imageCenterX();
    final tx = (courtPos.x - Court.width / 2) / Court.width;
    final imageX = centerX + tx * widthAtY;
    final imageY = _imageYForCourtY(courtPos.y) - z * zLiftForY(courtPos.y);
    return Vector2(imageX, imageY);
  }
}
