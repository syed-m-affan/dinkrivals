import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/components/ball_component.dart';
import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/util/court_projection.dart';

void main() {
  test('ball visual radius stays proportional to the painted court', () {
    expect(BallComponent.visualRadiusFor(0, 1), closeTo(2.05, 0.0001));
    expect(BallComponent.visualRadiusFor(100, 1), closeTo(4.3, 0.0001));
    expect(BallComponent.visualRadiusFor(150, 0.5), closeTo(2.15, 0.0001));
  });

  test('ball lifts more from ground near the camera than far away', () {
    const z = 100.0;
    final groundFar = CourtProjection.courtToScreen(
      Vector2(Court.width / 2, Court.top + 40),
      0,
    );
    final airborneFar = CourtProjection.courtToScreen(
      Vector2(Court.width / 2, Court.top + 40),
      z,
    );
    final groundNear = CourtProjection.courtToScreen(
      Vector2(Court.width / 2, Court.bottom - 40),
      0,
    );
    final airborneNear = CourtProjection.courtToScreen(
      Vector2(Court.width / 2, Court.bottom - 40),
      z,
    );

    final farGap = groundFar.y - airborneFar.y;
    final nearGap = groundNear.y - airborneNear.y;

    expect(nearGap, greaterThan(farGap));
    expect(nearGap / farGap, greaterThan(1.4));
  });

  test('ball radius scales with depth scale at the same altitude', () {
    final farDepthScale = CourtProjection.depthScaleForY(Court.top);
    final nearDepthScale = CourtProjection.depthScaleForY(Court.bottom);
    final farRadius = BallComponent.visualRadiusFor(50, farDepthScale);
    final nearRadius = BallComponent.visualRadiusFor(50, nearDepthScale);

    expect(nearRadius, greaterThan(farRadius));
  });
}
