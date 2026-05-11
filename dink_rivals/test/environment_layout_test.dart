import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/components/classic_environment_component.dart';
import 'package:dink_rivals/game/config/court_constants.dart';
import 'package:dink_rivals/game/config/environment_layout.dart';
import 'package:dink_rivals/game/systems/court_layout_system.dart';

void main() {
  test('classic environment prop placements are unique and bounded', () {
    final props = EnvironmentLayout.classicProps;

    expect(
      EnvironmentLayout.generatedBackgroundAsset,
      'environment/classic/park_background_generated.png',
    );
    expect(props.map((prop) => prop.id).toSet(), hasLength(props.length));
    expect(props, isNotEmpty);
    expect(
      props,
      everyElement(
        predicate<EnvironmentPropPlacement>(
          (prop) => prop.isOutsideActiveCourt || prop.mayUnderlapCourt,
        ),
      ),
    );
    expect(
      props,
      everyElement(
        predicate<EnvironmentPropPlacement>(
          (prop) => prop.avoidsBottomControlBand,
        ),
      ),
    );
    expect(
      props.map((prop) => prop.assetPath),
      everyElement(startsWith('environment/classic/')),
    );
  });

  test('classic environment includes required prop categories', () {
    final ids = EnvironmentLayout.classicProps.map((prop) => prop.id).join('|');

    expect(ids, contains('fence'));
    expect(ids, contains('tree'));
    expect(ids, contains('bench'));
    expect(ids, contains('lamp'));
    expect(ids, contains('sign'));
    expect(ids, contains('planter'));
    expect(ids, contains('shrub'));
    expect(ids, contains('bag'));
  });

  test('projected prop rectangles avoid court and control-critical bands', () {
    final layout = CourtLayoutSystem()..resize(Vector2(412, 915));
    final courtRect = _courtBounds(layout);
    const topHudBand = Rect.fromLTWH(0, 0, 412, 72);
    const bottomControlBand = Rect.fromLTWH(0, 915 - 180, 412, 180);

    for (final prop in EnvironmentLayout.classicProps) {
      final anchor = layout.courtToWorld(prop.courtAnchor);
      final depthScale = layout.depthScaleForY(prop.courtAnchor.y);
      final size = ClassicEnvironmentGeometry.propSize(
        imageWidth: _imageAspectFor(prop).width,
        imageHeight: _imageAspectFor(prop).height,
        width: layout.logicalToScreen(prop.logicalSize.x * depthScale),
        height: layout.logicalToScreen(prop.logicalSize.y * depthScale),
        preserveAspect: prop.preserveAspect,
      );
      final rect = ClassicEnvironmentGeometry.propRect(
        anchor: anchor,
        width: size.width,
        height: size.height,
        propAnchor: prop.anchor,
      );

      expect(
        !rect.overlaps(courtRect) || prop.mayUnderlapCourt,
        isTrue,
        reason:
            '${prop.id} should not overlap the active court unless marked as backdrop underlap',
      );
      expect(
        rect.overlaps(topHudBand),
        isFalse,
        reason: '${prop.id} should not overlap top HUD/feedback space',
      );
      expect(
        rect.overlaps(bottomControlBand),
        isFalse,
        reason: '${prop.id} should not overlap bottom control space',
      );
    }
  });

  test('classic environment preserves raster prop aspect ratios', () {
    final fence = EnvironmentLayout.classicProps
        .firstWhere((prop) => prop.id == 'far_fence_center');
    final requested = ClassicEnvironmentGeometry.propSize(
      imageWidth: 192,
      imageHeight: 160,
      width: 100,
      height: 54,
      preserveAspect: fence.preserveAspect,
    );

    expect(fence.preserveAspect, isTrue);
    expect(requested.width / requested.height, closeTo(192 / 160, 0.001));
    expect(requested.width, lessThan(100));
    expect(requested.height, 54);
  });
}

Rect _courtBounds(CourtLayoutSystem layout) {
  final corners = [
    layout.courtToWorld(Vector2(Court.left, Court.top)),
    layout.courtToWorld(Vector2(Court.right, Court.top)),
    layout.courtToWorld(Vector2(Court.right, Court.bottom)),
    layout.courtToWorld(Vector2(Court.left, Court.bottom)),
  ];
  final xs = corners.map((corner) => corner.x);
  final ys = corners.map((corner) => corner.y);
  return Rect.fromLTRB(
    xs.reduce((a, b) => a < b ? a : b),
    ys.reduce((a, b) => a < b ? a : b),
    xs.reduce((a, b) => a > b ? a : b),
    ys.reduce((a, b) => a > b ? a : b),
  );
}

Size _imageAspectFor(EnvironmentPropPlacement prop) {
  if (prop.assetPath.endsWith('far_fence_segment.png')) {
    return const Size(192, 160);
  }
  if (prop.assetPath.endsWith('tree_cluster.png')) {
    return const Size(192, 192);
  }
  if (prop.assetPath.endsWith('bench.png')) {
    return const Size(192, 128);
  }
  if (prop.assetPath.endsWith('lamp_post.png')) {
    return const Size(96, 192);
  }
  if (prop.assetPath.endsWith('banner_sign.png')) {
    return const Size(192, 96);
  }
  if (prop.assetPath.endsWith('park_courts_sign.png')) {
    return const Size(192, 96);
  }
  if (prop.assetPath.endsWith('planter_cluster.png')) {
    return const Size(128, 128);
  }
  if (prop.assetPath.endsWith('shrub_cluster.png')) {
    return const Size(192, 128);
  }
  if (prop.assetPath.endsWith('equipment_bag.png')) {
    return const Size(160, 128);
  }
  return Size(prop.logicalSize.x, prop.logicalSize.y);
}
