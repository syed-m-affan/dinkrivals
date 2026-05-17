import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/dink_rivals_game.dart';
import '../game/models/player_side.dart';
import '../services/save_service.dart';
import 'audio_provider.dart';
import 'haptics_provider.dart';

const bool _qaSeedEndMatch = bool.fromEnvironment(
  'DINK_RIVALS_QA_END_MATCH',
);
const String _qaEndMatchWinner = String.fromEnvironment(
  'DINK_RIVALS_QA_END_MATCH_WINNER',
  defaultValue: 'player',
);

final dinkRivalsGameProvider = Provider<DinkRivalsGame>((ref) {
  final saveData = ref.read(saveDataProvider);
  final game = DinkRivalsGame(
    audioService: ref.watch(audioServiceProvider),
    hapticsService: ref.watch(hapticsServiceProvider),
    controlMode: saveData.gameplayControlMode,
    selectedCourtId: saveData.activeCourtId,
    selectedPlayerCharacterId: saveData.activeCharacterId,
    selectedPaddleSkinId: saveData.activePaddleSkinId,
  );
  seedQaEndMatchForLaunch(
    game,
    enabled: _qaSeedEndMatch,
    winner: _qaEndMatchWinner,
  );
  return game;
});

@visibleForTesting
void seedQaEndMatchForLaunch(
  DinkRivalsGame game, {
  required bool enabled,
  required String winner,
}) {
  if (!enabled) {
    return;
  }

  final playerWon = winner == 'player';
  game.matchState
    ..playerScore = playerWon ? 11 : 8
    ..opponentScore = playerWon ? 6 : 11
    ..servingSide = playerWon ? PlayerSide.player : PlayerSide.opponent
    ..pointInProgress = false
    ..matchOver = true
    ..rallyCount = 7
    ..longestRally = 12;
}
