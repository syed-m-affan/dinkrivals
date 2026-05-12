import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/config/tuning_constants.dart';
import 'package:dink_rivals/game/systems/court_layout_system.dart';
import 'package:dink_rivals/game/util/court_projection.dart';

/// PERSP-009 perception assertions: properties the player must be able to
/// rely on through the new pinhole projection. These are not physics tests —
/// gameplay coordinates are unchanged — but they guard the perceptual
/// contract so future projection tuning cannot silently regress legibility.
void main() {
  test('a high lob lifts the ball clearly above the court surface', () {
    final layout = CourtLayoutSystem()..resize(Vector2(1080, 2400));
    final ground = layout.courtToWorld(
      Vector2(Court.width / 2, Court.playerStartY),
    );
    final apex = layout.courtToWorld(
      Vector2(Court.width / 2, Court.playerStartY),
      Tuning.lobInitialZ,
    );

    expect(ground.y - apex.y, greaterThan(60));
  });

  test('opponent baseline reads visibly behind the player baseline', () {
    final layout = CourtLayoutSystem()..resize(Vector2(1080, 2400));
    final far = layout.courtToWorld(Vector2(Court.width / 2, Court.top));
    final near = layout.courtToWorld(Vector2(Court.width / 2, Court.bottom));

    expect(near.y - far.y, greaterThan(400));
  });

  test('racket reach is visible at the projected scale of the player baseline',
      () {
    final layout = CourtLayoutSystem()..resize(Vector2(1080, 2400));
    final body = layout.courtToWorld(
      Vector2(Court.playerStartX, Court.playerStartY),
    );
    final tip = layout.courtToWorld(
      Vector2(Court.playerStartX, Court.playerStartY - Tuning.racketReach),
    );

    expect(body.y - tip.y, greaterThan(24));
  });

  test('z lift at near court is at least 1.5x the z lift at far court', () {
    expect(
      CourtProjection.zLiftForY(Court.bottom) /
          CourtProjection.zLiftForY(Court.top),
      greaterThan(1.5),
    );
  });

  test('net overlay has visible projected height and horizontal rails', () {
    final layout = CourtLayoutSystem()..resize(Vector2(1080, 2400));
    final leftGround = layout.courtToWorld(Vector2(Court.left, Court.netY));
    final rightGround = layout.courtToWorld(Vector2(Court.right, Court.netY));
    final leftTop = layout.courtToWorld(Vector2(Court.left, Court.netY), 86);
    final rightTop = layout.courtToWorld(Vector2(Court.right, Court.netY), 86);

    expect((leftTop.y - rightTop.y).abs(), lessThan(0.01));
    expect((leftGround.y - rightGround.y).abs(), lessThan(0.01));
    expect(leftGround.y - leftTop.y, greaterThan(12));
    expect(
      (rightTop.x - leftTop.x) - (rightGround.x - leftGround.x),
      closeTo(0, 0.01),
    );
  });
}
