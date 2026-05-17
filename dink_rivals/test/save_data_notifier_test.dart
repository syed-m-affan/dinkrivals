import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/game/models/character_unlock.dart';
import 'package:dink_rivals/game/models/court_unlock.dart';
import 'package:dink_rivals/game/models/gameplay_control_mode.dart';
import 'package:dink_rivals/game/models/paddle_skin.dart';
import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/services/save_service.dart';

ProviderContainer _container(SaveService service, SaveData initial) {
  return ProviderContainer(
    overrides: [
      saveServiceProvider.overrideWithValue(service),
      saveDataProvider.overrideWith(() => SaveDataNotifier(service, initial)),
    ],
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('setSoundEnabled updates state and persists', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = _container(service, const SaveData());
    addTearDown(container.dispose);

    await container.read(saveDataProvider.notifier).setSoundEnabled(false);

    expect(container.read(saveDataProvider).soundEnabled, isFalse);
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.soundEnabled, isFalse);
  });

  test('setHapticsEnabled updates state and persists', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = _container(service, const SaveData());
    addTearDown(container.dispose);

    await container.read(saveDataProvider.notifier).setHapticsEnabled(false);

    expect(container.read(saveDataProvider).hapticsEnabled, isFalse);
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.hapticsEnabled, isFalse);
  });

  test('setGameplayControlMode updates state and persists', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = _container(service, const SaveData());
    addTearDown(container.dispose);

    await container
        .read(saveDataProvider.notifier)
        .setGameplayControlMode(GameplayControlMode.classicRacketStick);

    expect(
      container.read(saveDataProvider).gameplayControlMode,
      GameplayControlMode.classicRacketStick,
    );
    final reloaded = await SaveService(prefs).load();
    expect(
        reloaded.gameplayControlMode, GameplayControlMode.classicRacketStick);
  });

  test('recordMatchCompleted increments match count and stars', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = _container(service, const SaveData(matchesCompleted: 2));
    addTearDown(container.dispose);

    await container.read(saveDataProvider.notifier).recordMatchCompleted();
    await container.read(saveDataProvider.notifier).recordMatchCompleted();

    expect(container.read(saveDataProvider).matchesCompleted, 4);
    expect(container.read(saveDataProvider).stars, 200);
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.matchesCompleted, 4);
    expect(reloaded.stars, 200);
  });

  test('recordClassicCupWin unlocks and persists trophy count', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = _container(service, const SaveData());
    addTearDown(container.dispose);

    await container.read(saveDataProvider.notifier).recordClassicCupWin();

    expect(container.read(saveDataProvider).classicCupWins, 1);
    expect(container.read(saveDataProvider).classicCupTrophyUnlocked, isTrue);
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.classicCupWins, 1);
  });

  test('addStars persists reward currency', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = _container(service, const SaveData(stars: 50));
    addTearDown(container.dispose);

    await container.read(saveDataProvider.notifier).addStars(100);

    expect(container.read(saveDataProvider).stars, 150);
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.stars, 150);
  });

  test('setTutorialSeen persists tutorial completion', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = _container(service, const SaveData());
    addTearDown(container.dispose);

    await container.read(saveDataProvider.notifier).setTutorialSeen(true);

    expect(container.read(saveDataProvider).tutorialSeen, isTrue);
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.tutorialSeen, isTrue);
  });

  test('unlockDinkStreakPaddle persists achievement state', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = _container(service, const SaveData());
    addTearDown(container.dispose);

    await container.read(saveDataProvider.notifier).unlockDinkStreakPaddle();
    await container.read(saveDataProvider.notifier).unlockDinkStreakPaddle();

    expect(container.read(saveDataProvider).dinkStreakPaddleUnlocked, isTrue);
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.dinkStreakPaddleUnlocked, isTrue);
  });

  test('selectCourt persists cosmetic court choice', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = _container(service, const SaveData());
    addTearDown(container.dispose);

    await container
        .read(saveDataProvider.notifier)
        .selectCourt(CourtUnlockIds.training);

    expect(container.read(saveDataProvider).activeCourtId,
        CourtUnlockIds.training);
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.activeCourtId, CourtUnlockIds.training);
  });

  test('selectPaddleSkin persists unlocked cosmetic accent choice', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = _container(
      service,
      const SaveData(dinkStreakPaddleUnlocked: true),
    );
    addTearDown(container.dispose);

    await container
        .read(saveDataProvider.notifier)
        .selectPaddleSkin(PaddleSkinIds.dinkStreak);

    expect(
      container.read(saveDataProvider).activePaddleSkinId,
      PaddleSkinIds.dinkStreak,
    );
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.activePaddleSkinId, PaddleSkinIds.dinkStreak);
  });

  test('selectPaddleSkin ignores locked cosmetic accent choice', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = _container(service, const SaveData());
    addTearDown(container.dispose);

    await container
        .read(saveDataProvider.notifier)
        .selectPaddleSkin(PaddleSkinIds.dinkStreak);

    expect(
      container.read(saveDataProvider).activePaddleSkinId,
      PaddleSkinIds.classic,
    );
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.activePaddleSkinId, PaddleSkinIds.classic);
  });

  test('unlockCharacter persists defeated rival unlocks', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = _container(service, const SaveData());
    addTearDown(container.dispose);

    await container
        .read(saveDataProvider.notifier)
        .unlockCharacter(CharacterUnlockIds.showman);

    expect(
        container.read(saveDataProvider).isCharacterUnlocked(
              CharacterUnlockIds.showman,
            ),
        isTrue);
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.isCharacterUnlocked(CharacterUnlockIds.showman), isTrue);
  });

  test('selectCharacter persists unlocked cosmetic player choice', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    const initial = SaveData(
      unlockedCharacterIds: [
        CharacterUnlockIds.rookie,
        CharacterUnlockIds.rallyQueen,
        CharacterUnlockIds.veteran,
      ],
    );
    final container = _container(service, initial);
    addTearDown(container.dispose);

    await container
        .read(saveDataProvider.notifier)
        .selectCharacter(CharacterUnlockIds.veteran);

    expect(
      container.read(saveDataProvider).activeCharacterId,
      CharacterUnlockIds.veteran,
    );
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.activeCharacterId, CharacterUnlockIds.veteran);
  });

  test('selectCharacter ignores locked characters', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = _container(service, const SaveData());
    addTearDown(container.dispose);

    await container
        .read(saveDataProvider.notifier)
        .selectCharacter(CharacterUnlockIds.showman);

    expect(
      container.read(saveDataProvider).activeCharacterId,
      CharacterUnlockIds.defaultSelected,
    );
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.activeCharacterId, CharacterUnlockIds.defaultSelected);
  });
}
