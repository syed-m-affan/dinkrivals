import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dink_rivals_game.dart';

/// Placeholder component left in the render tree for compatibility. The court
/// surface, lines, kitchens, scuffs, and edge shading now live entirely in
/// the painted bg image (`park_background_overhaul.png`) and the projection
/// is aligned (via `CourtProjection`) so logical court coordinates land
/// exactly on the painted court. Removing the component would shift the
/// render priority of every later component, so it stays as a no-op.
class CourtComponent extends Component {
  CourtComponent(this.game);

  static const String surfaceTextureAsset =
      'court/court_surface_texture_generated.png';

  final DinkRivalsGame game;

  @override
  void render(Canvas canvas) {
    // Intentionally empty — see class doc.
  }
}
