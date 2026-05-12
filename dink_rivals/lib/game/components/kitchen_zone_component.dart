import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dink_rivals_game.dart';

class KitchenZoneComponent extends Component {
  KitchenZoneComponent(this.game);

  final DinkRivalsGame game;

  @override
  void render(Canvas canvas) {
    // Kitchen zones are now part of the painted bg (`park_background_overhaul.png`)
    // and align with `Court.*KitchenY` via `CourtProjection`. Synthetic tint
    // and edge are skipped so the painted court reads cleanly.
  }

}
