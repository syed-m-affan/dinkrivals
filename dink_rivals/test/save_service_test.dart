import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/game/models/character_unlock.dart';
import 'package:dink_rivals/game/models/court_unlock.dart';
import 'package:dink_rivals/game/models/gameplay_control_mode.dart';
import 'package:dink_rivals/game/models/paddle_skin.dart';
import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/services/save_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load returns defaults when nothing is persisted', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);

    final data = await service.load();

    expect(data.soundEnabled, isTrue);
    expect(data.hapticsEnabled, isTrue);
    expect(data.gameplayControlMode, GameplayControlMode.classicRacketStick);
    expect(data.matchesCompleted, 0);
    expect(data.classicCupWins, 0);
    expect(data.classicCupTrophyUnlocked, isFalse);
    expect(data.stars, 0);
    expect(data.tutorialSeen, isFalse);
    expect(data.dinkStreakPaddleUnlocked, isFalse);
    expect(data.activePaddleSkinId, PaddleSkinIds.classic);
    expect(data.activeCourtId, CourtUnlockIds.defaultCourt);
    expect(data.unlockedCharacterIds, CharacterUnlockIds.defaultUnlocked);
    expect(data.activeCharacterId, CharacterUnlockIds.defaultSelected);
  });

  test('save then load round-trips all fields', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);

    const target = SaveData(
      soundEnabled: false,
      hapticsEnabled: false,
      gameplayControlMode: GameplayControlMode.classicRacketStick,
      matchesCompleted: 7,
      classicCupWins: 2,
      stars: 350,
      tutorialSeen: true,
      dinkStreakPaddleUnlocked: true,
      selectedPaddleSkinId: PaddleSkinIds.dinkStreak,
      selectedCourtId: CourtUnlockIds.training,
      unlockedCharacterIds: [
        CharacterUnlockIds.rookie,
        CharacterUnlockIds.rallyQueen,
        CharacterUnlockIds.showman,
      ],
      selectedCharacterId: CharacterUnlockIds.showman,
    );
    await service.save(target);

    final reloaded = await service.load();
    expect(reloaded, target);
  });

  test('a fresh service over the same prefs sees prior writes (restart sim)',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    await service
        .save(const SaveData(soundEnabled: false, hapticsEnabled: true));

    final fresh = SaveService(prefs);
    final reloaded = await fresh.load();
    expect(reloaded.soundEnabled, isFalse);
    expect(reloaded.hapticsEnabled, isTrue);
    expect(
        reloaded.gameplayControlMode, GameplayControlMode.classicRacketStick);
  });

  test('partial keys still produce a usable SaveData', () async {
    SharedPreferences.setMockInitialValues({'sound_enabled': false});
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);

    final data = await service.load();
    expect(data.soundEnabled, isFalse);
    expect(data.hapticsEnabled, isTrue);
    expect(data.gameplayControlMode, GameplayControlMode.classicRacketStick);
    expect(data.matchesCompleted, 0);
    expect(data.classicCupWins, 0);
    expect(data.stars, 0);
    expect(data.tutorialSeen, isFalse);
    expect(data.dinkStreakPaddleUnlocked, isFalse);
    expect(data.activePaddleSkinId, PaddleSkinIds.classic);
    expect(data.activeCourtId, CourtUnlockIds.defaultCourt);
    expect(data.unlockedCharacterIds, CharacterUnlockIds.defaultUnlocked);
    expect(data.activeCharacterId, CharacterUnlockIds.defaultSelected);
  });

  test('SaveData copyWith leaves untouched fields alone', () {
    const original = SaveData(matchesCompleted: 5);
    final updated = original.copyWith(matchesCompleted: 6);

    expect(updated.matchesCompleted, 6);
    expect(updated.soundEnabled, original.soundEnabled);
    expect(updated.hapticsEnabled, original.hapticsEnabled);
    expect(updated.gameplayControlMode, original.gameplayControlMode);
    expect(updated.classicCupWins, original.classicCupWins);
    expect(updated.stars, original.stars);
    expect(updated.tutorialSeen, original.tutorialSeen);
    expect(
      updated.dinkStreakPaddleUnlocked,
      original.dinkStreakPaddleUnlocked,
    );
    expect(updated.selectedPaddleSkinId, original.selectedPaddleSkinId);
    expect(updated.selectedCourtId, original.selectedCourtId);
    expect(updated.unlockedCharacterIds, original.unlockedCharacterIds);
    expect(updated.selectedCharacterId, original.selectedCharacterId);
  });

  test('load ignores locked selected paddle skin ids', () async {
    SharedPreferences.setMockInitialValues({
      'dink_streak_paddle_unlocked': false,
      'selected_paddle_skin_id': PaddleSkinIds.dinkStreak,
    });
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);

    final data = await service.load();

    expect(data.dinkStreakPaddleUnlocked, isFalse);
    expect(data.selectedPaddleSkinId, PaddleSkinIds.classic);
    expect(data.activePaddleSkinId, PaddleSkinIds.classic);
  });
}
