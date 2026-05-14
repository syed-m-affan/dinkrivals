import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/systems/court_layout_system.dart';
import 'package:dink_rivals/game/systems/touch_input_controller.dart';

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

  test('court fits inside the visible play area on a tall portrait phone', () {
    final size = Vector2(1080, 2400);
    final layout = CourtLayoutSystem()..resize(size);

    final far = layout.courtToWorld(Vector2(Court.width / 2, Court.top));
    final near = layout.courtToWorld(Vector2(Court.width / 2, Court.bottom));

    expect(far.y, greaterThanOrEqualTo(0));
    expect(near.y, lessThanOrEqualTo(size.y));

    final controls = TouchControlLayout(size);
    final swingTop = controls.swingCenter.y - controls.swingVisualRadius;
    final moveTop = controls.moveCenter.y - controls.moveVisualRadius;
    final controlTop = swingTop < moveTop ? swingTop : moveTop;

    expect(near.y, lessThan(controlTop));
  });

  test('layout preserves the projection trapezoid', () {
    final layout = CourtLayoutSystem()..resize(Vector2(1080, 2400));

    final farLeft = layout.courtToWorld(Vector2(Court.left, Court.top));
    final farRight = layout.courtToWorld(Vector2(Court.right, Court.top));
    final nearLeft = layout.courtToWorld(Vector2(Court.left, Court.bottom));
    final nearRight = layout.courtToWorld(Vector2(Court.right, Court.bottom));

    final farWidth = farRight.x - farLeft.x;
    final nearWidth = nearRight.x - nearLeft.x;

    expect(nearWidth / farWidth, greaterThan(1.35));
    expect(nearWidth / farWidth, lessThan(1.60));
  });

  test('logicalToScreen of court length is finite and positive', () {
    final layout = CourtLayoutSystem()..resize(Vector2(1080, 2400));

    final mapped = layout.logicalToScreen(Court.length);
    expect(mapped, greaterThan(0));
    expect(mapped.isFinite, isTrue);
  });
}
