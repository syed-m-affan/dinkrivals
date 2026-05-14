import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dink_rivals_game.dart';

class KitchenZoneComponent extends Component {
  KitchenZoneComponent(this.game);

  final DinkRivalsGame game;

  @override
  void render(Canvas canvas) {
    // The current visual pass uses a graybox court guide. Kitchen boundaries
    // are drawn by CourtComponent so projection and line readability can be
    // tuned before final environment art exists.
  }

}
