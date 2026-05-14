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

  test('z lift at near court is clearly stronger than far court', () {
    expect(
      CourtProjection.zLiftForY(Court.bottom) /
          CourtProjection.zLiftForY(Court.top),
      greaterThan(1.35),
    );
  });

  test('gameplay net boundary lands above visual center in perspective', () {
    final layout = CourtLayoutSystem()..resize(Vector2(1080, 2400));
    final left = layout.courtToWorld(Vector2(Court.left, Court.netY));
    final right = layout.courtToWorld(Vector2(Court.right, Court.netY));
    final far = layout.courtToWorld(Vector2(Court.width / 2, Court.top));
    final near = layout.courtToWorld(Vector2(Court.width / 2, Court.bottom));

    expect((left.y - right.y).abs(), lessThan(0.01));
    expect(left.y, lessThan((far.y + near.y) / 2));
    expect(right.x - left.x, greaterThan(400));
  });
}
