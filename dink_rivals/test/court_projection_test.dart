import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/util/court_projection.dart';

void main() {
  test('courtToScreen is monotonic in x and y', () {
    final left = CourtProjection.courtToScreen(Vector2(20, 100), 0);
    final right = CourtProjection.courtToScreen(Vector2(120, 100), 0);
    final near = CourtProjection.courtToScreen(Vector2(20, 300), 0);

    expect(right.x, greaterThan(left.x));
    expect(near.y, greaterThan(left.y));
  });

  test('increasing z displaces rendered y upward', () {
    final ground = CourtProjection.courtToScreen(Vector2(100, 200), 0);
    final airborne = CourtProjection.courtToScreen(Vector2(100, 200), 40);

    expect(airborne.y, lessThan(ground.y));
  });

  test('net y maps consistently when ball is on the ground', () {
    final left = CourtProjection.courtToScreen(Vector2(0, Court.netY), 0);
    final middle =
        CourtProjection.courtToScreen(Vector2(Court.width / 2, Court.netY), 0);
    final right =
        CourtProjection.courtToScreen(Vector2(Court.width, Court.netY), 0);

    expect(middle.y, left.y);
    expect(right.y, left.y);
  });

  test('near baseline projects much wider than far baseline', () {
    final farLeft =
        CourtProjection.courtToScreen(Vector2(Court.left, Court.top), 0);
    final farRight =
        CourtProjection.courtToScreen(Vector2(Court.right, Court.top), 0);
    final nearLeft =
        CourtProjection.courtToScreen(Vector2(Court.left, Court.bottom), 0);
    final nearRight =
        CourtProjection.courtToScreen(Vector2(Court.right, Court.bottom), 0);

    final farWidth = farRight.x - farLeft.x;
    final nearWidth = nearRight.x - nearLeft.x;

    expect(nearWidth / farWidth, greaterThan(2.0));
    expect(nearWidth / farWidth, lessThan(2.25));
  });

  test('painted court occupies portrait-friendly aspect inside bg image', () {
    final farLeft =
        CourtProjection.courtToScreen(Vector2(Court.left, Court.top), 0);
    final farRight =
        CourtProjection.courtToScreen(Vector2(Court.right, Court.top), 0);
    final nearLeft =
        CourtProjection.courtToScreen(Vector2(Court.left, Court.bottom), 0);
    final nearRight =
        CourtProjection.courtToScreen(Vector2(Court.right, Court.bottom), 0);

    final width = nearRight.x - nearLeft.x;
    final height = nearLeft.y - farLeft.y;
    // Painted court in the bg image is taller than wide so it fits a portrait
    // phone after cover-fit.
    expect(width / height, lessThan(1.4));
    expect(farRight.x - farLeft.x, lessThan(width));
  });

  test('depth scale grows toward the near court', () {
    expect(
      CourtProjection.depthScaleForY(Court.bottom),
      greaterThan(CourtProjection.depthScaleForY(Court.top)),
    );
  });

  test('visual scale boosts the near player beyond raw projection scale', () {
    final rawPlayerScale = CourtProjection.depthScaleForY(Court.playerStartY);
    final visualPlayerScale =
        CourtProjection.visualScaleForY(Court.playerStartY);
    final visualOpponentScale =
        CourtProjection.visualScaleForY(Court.opponentStartY);

    expect(visualPlayerScale, greaterThan(rawPlayerScale));
    expect(visualPlayerScale, greaterThan(1.10));
    expect(visualOpponentScale, lessThan(visualPlayerScale));
  });

  test('net y maps to the concept-composition net line', () {
    final net =
        CourtProjection.courtToScreen(Vector2(Court.width / 2, Court.netY), 0);
    final far =
        CourtProjection.courtToScreen(Vector2(Court.width / 2, Court.top), 0);
    final near = CourtProjection.courtToScreen(
      Vector2(Court.width / 2, Court.bottom),
      0,
    );

    expect(net.y, closeTo(CourtProjection.paintedNetY, 0.1));
    expect(net.y, lessThan((far.y + near.y) / 2));
  });

  test('kitchen lines align to projection environment v2 paint', () {
    final opponentKitchen = CourtProjection.courtToScreen(
      Vector2(Court.width / 2, Court.opponentKitchenTopY),
      0,
    );
    final playerKitchen = CourtProjection.courtToScreen(
      Vector2(Court.width / 2, Court.playerKitchenBottomY),
      0,
    );

    expect(opponentKitchen.y, closeTo(564, 1));
    expect(playerKitchen.y, closeTo(722, 1));
  });

  test('z lift increases toward the near court', () {
    expect(
      CourtProjection.zLiftForY(Court.bottom),
      greaterThan(CourtProjection.zLiftForY(Court.top)),
    );

    final lobZ = 100.0;
    final groundFar =
        CourtProjection.courtToScreen(Vector2(110, Court.top + 40), 0);
    final airborneFar =
        CourtProjection.courtToScreen(Vector2(110, Court.top + 40), lobZ);
    final groundNear =
        CourtProjection.courtToScreen(Vector2(110, Court.bottom - 40), 0);
    final airborneNear =
        CourtProjection.courtToScreen(Vector2(110, Court.bottom - 40), lobZ);

    final farLift = groundFar.y - airborneFar.y;
    final nearLift = groundNear.y - airborneNear.y;

    expect(nearLift, greaterThan(farLift));
  });

  test('depth scale derives from camera distance up to readability clamp', () {
    final depthRatio = CourtProjection.depthScaleForY(Court.top) /
        CourtProjection.depthScaleForY(Court.bottom);
    final distanceRatio = CourtProjection.distanceForY(Court.bottom) /
        CourtProjection.distanceForY(Court.top);

    // Floor clamp may slightly widen the depth scale at the far end relative
    // to the pure distance ratio; allow up to 15% deviation so the clamp does
    // not block aggressive perspective tuning.
    expect((depthRatio - distanceRatio).abs() / distanceRatio, lessThan(0.15));
  });

  test('depth scale stays above readability floor', () {
    for (var y = -Court.length; y <= Court.length * 2; y += Court.length / 10) {
      expect(CourtProjection.depthScaleForY(y), greaterThanOrEqualTo(0.40));
    }
  });

  test('kitchen lines preserve real pickleball depth in world space', () {
    expect(Court.playerKitchenBottomY - Court.netY,
        closeTo(7 * Court.feetToUnits, 0.001));
    expect(Court.netY - Court.opponentKitchenTopY,
        closeTo(7 * Court.feetToUnits, 0.001));
    expect(Court.netY - Court.top, Court.bottom - Court.netY);
  });
}
