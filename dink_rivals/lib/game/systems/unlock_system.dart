import '../models/character_unlock.dart';
import '../models/save_data.dart';

class UnlockSystem {
  const UnlockSystem();

  static const int dinkStreakPaddleRequiredContacts = 5;

  bool playerWonMatch({
    required int playerScore,
    required int opponentScore,
  }) {
    return playerScore > opponentScore;
  }

  bool shouldUnlockDefeatedRival({
    required bool playerWon,
    required String? rivalId,
    required SaveData saveData,
  }) {
    if (!playerWon || rivalId == null) {
      return false;
    }
    return CharacterUnlockIds.isKnown(rivalId) &&
        !saveData.isCharacterUnlocked(rivalId);
  }

  bool shouldUnlockDinkStreakPaddle({
    required int playerDinkContactsThisMatch,
    required SaveData saveData,
  }) {
    return !saveData.dinkStreakPaddleUnlocked &&
        playerDinkContactsThisMatch >= dinkStreakPaddleRequiredContacts;
  }

  bool shouldRecordClassicCupWin({
    required bool previouslyChampion,
    required bool nowChampion,
  }) {
    return nowChampion && !previouslyChampion;
  }
}
