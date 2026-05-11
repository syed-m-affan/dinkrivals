import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/dink_rivals_game.dart';
import 'audio_provider.dart';
import 'haptics_provider.dart';

final dinkRivalsGameProvider = Provider<DinkRivalsGame>((ref) {
  return DinkRivalsGame(
    audioService: ref.watch(audioServiceProvider),
    hapticsService: ref.watch(hapticsServiceProvider),
  );
});
