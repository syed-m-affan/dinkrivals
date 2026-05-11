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

    expect(nearWidth / farWidth, greaterThan(1.5));
  });

  test('projected court aspect is portrait friendly', () {
    final farLeft =
        CourtProjection.courtToScreen(Vector2(Court.left, Court.top), 0);
    final farRight =
        CourtProjection.courtToScreen(Vector2(Court.right, Court.top), 0);
    final nearLeft =
        CourtProjection.courtToScreen(Vector2(Court.left, Court.bottom), 0);
    final nearRight =
        CourtProjection.courtToScreen(Vector2(Court.right, Court.bottom), 0);

    final minX = [farLeft.x, farRight.x, nearLeft.x, nearRight.x]
        .reduce((a, b) => a < b ? a : b);
    final maxX = [farLeft.x, farRight.x, nearLeft.x, nearRight.x]
        .reduce((a, b) => a > b ? a : b);
    final minY = [farLeft.y, farRight.y, nearLeft.y, nearRight.y]
        .reduce((a, b) => a < b ? a : b);
    final maxY = [farLeft.y, farRight.y, nearLeft.y, nearRight.y]
        .reduce((a, b) => a > b ? a : b);

    expect((maxX - minX) / (maxY - minY), lessThan(0.6));
  });

  test('depth scale grows toward the near court', () {
    expect(
      CourtProjection.depthScaleForY(Court.bottom),
      greaterThan(CourtProjection.depthScaleForY(Court.top)),
    );
  });
}
