import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/systems/court_layout_system.dart';

void main() {
  test('court layout maps near baseline below far baseline after resize', () {
    final layout = CourtLayoutSystem()..resize(Vector2(360, 720));

    final far = layout.courtToWorld(Vector2(Court.width / 2, Court.top));
    final near = layout.courtToWorld(Vector2(Court.width / 2, Court.bottom));

    expect(near.y, greaterThan(far.y));
  });

  test('logical units scale with resized court', () {
    final layout = CourtLayoutSystem()..resize(Vector2(360, 720));

    expect(layout.logicalToScreen(10), greaterThan(0));
    expect(layout.courtScale, greaterThan(0));
  });
}
