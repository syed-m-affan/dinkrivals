import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../dink_rivals_game.dart';

class KitchenZoneComponent extends Component {
  KitchenZoneComponent(this.game);

  final DinkRivalsGame game;

  @override
  void render(Canvas canvas) {
    // Kitchen boundaries are drawn by CourtComponent so their screen position
    // stays tied to the gameplay projection rather than the background art.
  }
}
