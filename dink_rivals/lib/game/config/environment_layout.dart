import 'package:flutter/foundation.dart';
import 'package:flame/components.dart';

import 'court_constants.dart';

enum EnvironmentPropAnchor {
  bottomCenter,
  center,
}

@immutable
class EnvironmentPropPlacement {
  const EnvironmentPropPlacement({
    required this.id,
    required this.assetPath,
    required this.courtAnchor,
    required this.logicalSize,
    this.anchor = EnvironmentPropAnchor.bottomCenter,
    this.opacity = 1,
    this.mayUnderlapCourt = false,
    this.preserveAspect = true,
  });

  final String id;
  final String assetPath;
  final Vector2 courtAnchor;
  final Vector2 logicalSize;
  final EnvironmentPropAnchor anchor;
  final double opacity;
  final bool mayUnderlapCourt;
  final bool preserveAspect;

  bool get isOutsideActiveCourt {
    const margin = 8.0;
    return courtAnchor.x < Court.left - margin ||
        courtAnchor.x > Court.right + margin ||
        courtAnchor.y < Court.top - margin ||
        courtAnchor.y > Court.bottom + margin;
  }

  bool get avoidsBottomControlBand => courtAnchor.y < Court.bottom + 12;
}

class EnvironmentLayout {
  static const String groundTileAsset =
      'environment/classic/off_court_ground_tile.png';
  static const String softShadowAsset =
      'environment/shared/soft_shadow_patch.png';

  static final List<EnvironmentPropPlacement> classicProps = [
    EnvironmentPropPlacement(
      id: 'far_fence_left',
      assetPath: 'environment/classic/far_fence_segment.png',
      courtAnchor: Vector2(-34, 36),
      logicalSize: Vector2(72, 56),
      anchor: EnvironmentPropAnchor.center,
      opacity: 0.62,
      mayUnderlapCourt: true,
    ),
    EnvironmentPropPlacement(
      id: 'far_fence_center',
      assetPath: 'environment/classic/far_fence_segment.png',
      courtAnchor: Vector2(110, 34),
      logicalSize: Vector2(78, 60),
      anchor: EnvironmentPropAnchor.center,
      opacity: 0.62,
      mayUnderlapCourt: true,
    ),
    EnvironmentPropPlacement(
      id: 'far_fence_right',
      assetPath: 'environment/classic/far_fence_segment.png',
      courtAnchor: Vector2(254, 36),
      logicalSize: Vector2(72, 56),
      anchor: EnvironmentPropAnchor.center,
      opacity: 0.62,
      mayUnderlapCourt: true,
    ),
    EnvironmentPropPlacement(
      id: 'tree_left',
      assetPath: 'environment/classic/tree_cluster.png',
      courtAnchor: Vector2(-118, 92),
      logicalSize: Vector2(70, 70),
    ),
    EnvironmentPropPlacement(
      id: 'tree_right',
      assetPath: 'environment/classic/tree_cluster.png',
      courtAnchor: Vector2(338, 96),
      logicalSize: Vector2(72, 72),
    ),
    EnvironmentPropPlacement(
      id: 'tree_back_left',
      assetPath: 'environment/classic/tree_cluster.png',
      courtAnchor: Vector2(-54, 54),
      logicalSize: Vector2(46, 46),
      opacity: 0.72,
      mayUnderlapCourt: true,
    ),
    EnvironmentPropPlacement(
      id: 'tree_back_right',
      assetPath: 'environment/classic/tree_cluster.png',
      courtAnchor: Vector2(274, 58),
      logicalSize: Vector2(48, 48),
      opacity: 0.72,
      mayUnderlapCourt: true,
    ),
    EnvironmentPropPlacement(
      id: 'bench_left',
      assetPath: 'environment/classic/bench.png',
      courtAnchor: Vector2(-82, 236),
      logicalSize: Vector2(64, 42),
    ),
    EnvironmentPropPlacement(
      id: 'lamp_right',
      assetPath: 'environment/classic/lamp_post.png',
      courtAnchor: Vector2(300, 206),
      logicalSize: Vector2(34, 72),
    ),
    EnvironmentPropPlacement(
      id: 'banner_back',
      assetPath: 'environment/classic/banner_sign.png',
      courtAnchor: Vector2(164, 34),
      logicalSize: Vector2(60, 40),
      anchor: EnvironmentPropAnchor.center,
      opacity: 0.9,
      mayUnderlapCourt: true,
    ),
    EnvironmentPropPlacement(
      id: 'shrubs_back_left',
      assetPath: 'environment/classic/shrub_cluster.png',
      courtAnchor: Vector2(-74, 42),
      logicalSize: Vector2(74, 42),
      mayUnderlapCourt: true,
    ),
    EnvironmentPropPlacement(
      id: 'shrubs_back_right',
      assetPath: 'environment/classic/shrub_cluster.png',
      courtAnchor: Vector2(294, 46),
      logicalSize: Vector2(74, 42),
      mayUnderlapCourt: true,
    ),
    EnvironmentPropPlacement(
      id: 'bag_left',
      assetPath: 'environment/classic/equipment_bag.png',
      courtAnchor: Vector2(-62, 330),
      logicalSize: Vector2(38, 28),
    ),
    EnvironmentPropPlacement(
      id: 'bag_right',
      assetPath: 'environment/classic/equipment_bag.png',
      courtAnchor: Vector2(272, 314),
      logicalSize: Vector2(30, 24),
      opacity: 0.85,
    ),
  ];
}
