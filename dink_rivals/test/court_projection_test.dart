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
    final middle = CourtProjection.courtToScreen(Vector2(Court.width / 2, Court.netY), 0);
    final right = CourtProjection.courtToScreen(Vector2(Court.width, Court.netY), 0);

    expect(middle.y, left.y);
    expect(right.y, left.y);
  });
}
