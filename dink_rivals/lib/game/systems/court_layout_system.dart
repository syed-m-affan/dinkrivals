import 'dart:math' as math;

import 'package:flame/components.dart';

import '../config/court_constants.dart';
import '../util/court_projection.dart';

class CourtLayoutSystem {
  static const double minTopHudReserve = 72;
  static const double minBottomControlReserve = 180;

  double _courtScale = 1;
  Vector2 _courtOffset = Vector2.zero();
  Vector2 _projectedMin = Vector2.zero();

  double get courtScale => _courtScale;

  void resize(Vector2 size) {
    final projectedCorners = <Vector2>[
      CourtProjection.courtToScreen(Vector2(Court.left, Court.top), 0),
      CourtProjection.courtToScreen(Vector2(Court.right, Court.top), 0),
      CourtProjection.courtToScreen(Vector2(Court.right, Court.bottom), 0),
      CourtProjection.courtToScreen(Vector2(Court.left, Court.bottom), 0),
    ];
    final minX = projectedCorners
        .map((corner) => corner.x)
        .reduce((a, b) => a < b ? a : b);
    final maxX = projectedCorners
        .map((corner) => corner.x)
        .reduce((a, b) => a > b ? a : b);
    final minY = projectedCorners
        .map((corner) => corner.y)
        .reduce((a, b) => a < b ? a : b);
    final maxY = projectedCorners
        .map((corner) => corner.y)
        .reduce((a, b) => a > b ? a : b);
    final projectedWidth = maxX - minX;
    final projectedHeight = maxY - minY;
    final topReserve = math.min(size.y * 0.10, minTopHudReserve);
    final bottomReserve = math.min(size.y * 0.18, minBottomControlReserve);
    final availableHeight = math.max(1.0, size.y - topReserve - bottomReserve);

    _projectedMin = Vector2(minX, minY);
    _courtScale = (size.x * 0.94 / projectedWidth)
        .clamp(0.1, availableHeight / projectedHeight)
        .toDouble();
    _courtOffset = Vector2(
      (size.x - projectedWidth * _courtScale) / 2,
      topReserve + (availableHeight - projectedHeight * _courtScale) / 2,
    );
  }

  Vector2 courtToWorld(Vector2 courtPosition, [double z = 0]) {
    final projected = CourtProjection.courtToScreen(courtPosition, z);
    return Vector2(
      _courtOffset.x + (projected.x - _projectedMin.x) * _courtScale,
      _courtOffset.y + (projected.y - _projectedMin.y) * _courtScale,
    );
  }

  double logicalToScreen(double logicalUnits) => logicalUnits * _courtScale;

  double depthScaleForY(double courtY) =>
      CourtProjection.depthScaleForY(courtY);
}
