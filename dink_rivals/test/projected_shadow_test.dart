import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/visual_palette.dart';
import 'package:dink_rivals/game/util/projected_shadow.dart';

void main() {
  test('directional shadow offset uses shared screen-space direction', () {
    final offset = ProjectedShadow.offset();

    expect(offset.dx, VisualPalette.shadowScreenOffset.dx);
    expect(offset.dy, VisualPalette.shadowScreenOffset.dy);
  });

  test('shadow elevation increases offset without exceeding configured alpha',
      () {
    final groundOffset = ProjectedShadow.offset();
    final elevatedOffset = ProjectedShadow.offset(elevationFraction: 1);
    final paint = ProjectedShadow.paint(1);

    expect(elevatedOffset.dx, greaterThan(groundOffset.dx));
    expect(elevatedOffset.dy, greaterThan(groundOffset.dy));
    expect(
      paint.color.a,
      closeTo(VisualPalette.projectedShadowMaxAlpha, 0.000001),
    );
  });

  test('directional oval rect is shifted from source center', () {
    final rect = ProjectedShadow.directionalOvalRect(
      center: Offset.zero,
      width: 20,
      height: 8,
      offsetScale: 0.5,
    );

    expect(rect.center.dx, VisualPalette.shadowScreenOffset.dx * 0.5);
    expect(rect.center.dy, VisualPalette.shadowScreenOffset.dy * 0.5);
    expect(rect.width, 20);
    expect(rect.height, 8);
  });

  test('negative scale is clamped to prevent flipped shadows', () {
    final offset = ProjectedShadow.offset(scale: -1);

    expect(offset.dx, 0);
    expect(offset.dy, 0);
  });
}
