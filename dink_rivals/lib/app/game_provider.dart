import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/dink_rivals_game.dart';

final dinkRivalsGameProvider = Provider<DinkRivalsGame>((ref) {
  return DinkRivalsGame();
});
