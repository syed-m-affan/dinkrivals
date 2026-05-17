import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/models/character_unlock.dart';
import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/game/systems/unlock_system.dart';

void main() {
  const system = UnlockSystem();

  test('defeated rival unlock requires player win, known rival, and lock state',
      () {
    expect(
      system.shouldUnlockDefeatedRival(
        playerWon: true,
        rivalId: CharacterUnlockIds.rallyQueen,
        saveData: const SaveData(),
      ),
      isTrue,
    );
    expect(
      system.shouldUnlockDefeatedRival(
        playerWon: false,
        rivalId: CharacterUnlockIds.rallyQueen,
        saveData: const SaveData(),
      ),
      isFalse,
    );
    expect(
      system.shouldUnlockDefeatedRival(
        playerWon: true,
        rivalId: 'missing_rival',
        saveData: const SaveData(),
      ),
      isFalse,
    );
    expect(
      system.shouldUnlockDefeatedRival(
        playerWon: true,
        rivalId: CharacterUnlockIds.rookie,
        saveData: const SaveData(),
      ),
      isFalse,
    );
  });

  test('dink streak paddle unlock requires five dinks and is idempotent', () {
    expect(
      system.shouldUnlockDinkStreakPaddle(
        playerDinkContactsThisMatch: 4,
        saveData: const SaveData(),
      ),
      isFalse,
    );
    expect(
      system.shouldUnlockDinkStreakPaddle(
        playerDinkContactsThisMatch: 5,
        saveData: const SaveData(),
      ),
      isTrue,
    );
    expect(
      system.shouldUnlockDinkStreakPaddle(
        playerDinkContactsThisMatch: 8,
        saveData: const SaveData(dinkStreakPaddleUnlocked: true),
      ),
      isFalse,
    );
  });

  test('classic cup win records only on first champion transition', () {
    expect(
      system.shouldRecordClassicCupWin(
        previouslyChampion: false,
        nowChampion: true,
      ),
      isTrue,
    );
    expect(
      system.shouldRecordClassicCupWin(
        previouslyChampion: true,
        nowChampion: true,
      ),
      isFalse,
    );
    expect(
      system.shouldRecordClassicCupWin(
        previouslyChampion: false,
        nowChampion: false,
      ),
      isFalse,
    );
  });

  test('playerWonMatch uses completed score comparison', () {
    expect(system.playerWonMatch(playerScore: 11, opponentScore: 8), isTrue);
    expect(system.playerWonMatch(playerScore: 8, opponentScore: 11), isFalse);
    expect(system.playerWonMatch(playerScore: 0, opponentScore: 0), isFalse);
  });
}
