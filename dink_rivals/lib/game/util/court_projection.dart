import 'dart:math' as math;

import 'package:flame/components.dart';

import '../config/court_constants.dart';

/// Projects logical court coordinates into image-space control points for the
/// current painted court guide. The logical court corners and net line map to
/// fixed visual control points, so any line, player, ball, or shadow rendered
/// with `courtToWorld` shares the same perspective.
///
/// This file defines the projection in image-pixel space; `CourtLayoutSystem`
/// applies a cover-fit transform so the projection lands on actual screen
/// pixels at any device size.
class CourtProjection {
  // Virtual design-space intrinsics for the projection-locked background.
  static const double imageWidth = 979.0;
  static const double imageHeight = 1606.0;

  // Image-space control points measured from projection_environment_v2.png.
  // The v2 art was accepted as the next candidate direction by human QA, so
  // gameplay geometry follows the painting rather than the failed v1 guide.
  static const double paintedFarY = 386.0;
  static const double paintedNetY = 638.0;
  static const double paintedNearY = 1140.0;
  static const double paintedFarLeftX = 295.0;
  static const double paintedFarRightX = 677.0;
  static const double paintedNetLeftX = 200.0;
  static const double paintedNetRightX = 777.0;
  static const double paintedNearLeftX = 78.0;
  static const double paintedNearRightX = 901.0;
  static const double _upperSegmentPerspectiveExponent = 0.91;
  static const double _lowerSegmentPerspectiveExponent = 1.56;

  // Pixels of vertical lift per court z-unit at the near baseline. Z lift at
  // any other y scales linearly with widthAtY so the lift sells perspective.
  static const double _zLiftAtNear = 1.40;
  static const double _minDepthScale = 0.40;
  static const double _maxDepthScale = 1.15;
  static const double _minActorVisualScale = 0.70;

  static double _t(double courtY) {
    return (courtY / Court.length).clamp(0.0, 1.0).toDouble();
  }

  static double _segmentT(double localT, double exponent) {
    return math.pow(localT.clamp(0.0, 1.0), exponent).toDouble();
  }

  static double _imageYForCourtY(double courtY) {
    final clampedY = courtY.clamp(Court.top, Court.bottom).toDouble();
    if (clampedY <= Court.netY) {
      final t =
          _segmentT(clampedY / Court.netY, _upperSegmentPerspectiveExponent);
      return paintedFarY + t * (paintedNetY - paintedFarY);
    }

    final t = _segmentT(
      (clampedY - Court.netY) / (Court.bottom - Court.netY),
      _lowerSegmentPerspectiveExponent,
    );
    return paintedNetY + t * (paintedNearY - paintedNetY);
  }

  static ({double left, double right}) _imageBoundsAtCourtY(double courtY) {
    final clampedY = courtY.clamp(Court.top, Court.bottom).toDouble();
    if (clampedY <= Court.netY) {
      final t =
          _segmentT(clampedY / Court.netY, _upperSegmentPerspectiveExponent);
      return (
        left: paintedFarLeftX + t * (paintedNetLeftX - paintedFarLeftX),
        right: paintedFarRightX + t * (paintedNetRightX - paintedFarRightX),
      );
    }

    final t = _segmentT(
      (clampedY - Court.netY) / (Court.bottom - Court.netY),
      _lowerSegmentPerspectiveExponent,
    );
    return (
      left: paintedNetLeftX + t * (paintedNearLeftX - paintedNetLeftX),
      right: paintedNetRightX + t * (paintedNearRightX - paintedNetRightX),
    );
  }

  static double _imageWidthAtCourtY(double courtY) {
    final bounds = _imageBoundsAtCourtY(courtY);
    return bounds.right - bounds.left;
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
    final scaled = depth * (1.10 + nearT * 0.24);
    return scaled < _minActorVisualScale ? _minActorVisualScale : scaled;
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
    final bounds = _imageBoundsAtCourtY(courtPos.y);
    final tx = courtPos.x / Court.width;
    final imageX = bounds.left + tx * (bounds.right - bounds.left);
    final imageY = _imageYForCourtY(courtPos.y) - z * zLiftForY(courtPos.y);
    return Vector2(imageX, imageY);
  }
}
