import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/app/game_provider.dart';
import 'package:dink_rivals/app/haptics_provider.dart';
import 'package:dink_rivals/game/models/character_unlock.dart';
import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/services/audio_service.dart';
import 'package:dink_rivals/services/haptics_service.dart';
import 'package:dink_rivals/services/save_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('active game survives save-data updates after match completion',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = ProviderContainer(
      overrides: [
        saveServiceProvider.overrideWithValue(service),
        saveDataProvider.overrideWith(
          () => SaveDataNotifier(service, const SaveData()),
        ),
        audioServiceProvider.overrideWithValue(FakeAudioService()),
        hapticsServiceProvider.overrideWithValue(FakeHapticsService()),
      ],
    );
    addTearDown(container.dispose);

    final game = container.read(dinkRivalsGameProvider);
    game.matchState
      ..playerScore = 11
      ..opponentScore = 6
      ..matchOver = true;

    await container.read(saveDataProvider.notifier).recordMatchCompleted();

    final retainedGame = container.read(dinkRivalsGameProvider);
    expect(retainedGame, same(game));
    expect(retainedGame.matchState.playerScore, 11);
    expect(retainedGame.matchState.opponentScore, 6);
  });

  test('game starts with persisted selected player character', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = SaveService(prefs);
    final container = ProviderContainer(
      overrides: [
        saveServiceProvider.overrideWithValue(service),
        saveDataProvider.overrideWith(
          () => SaveDataNotifier(
            service,
            const SaveData(
              unlockedCharacterIds: [
                CharacterUnlockIds.rookie,
                CharacterUnlockIds.rallyQueen,
                CharacterUnlockIds.veteran,
              ],
              selectedCharacterId: CharacterUnlockIds.veteran,
            ),
          ),
        ),
        audioServiceProvider.overrideWithValue(FakeAudioService()),
        hapticsServiceProvider.overrideWithValue(FakeHapticsService()),
      ],
    );
    addTearDown(container.dispose);

    final game = container.read(dinkRivalsGameProvider);

    expect(game.selectedPlayerCharacterId, CharacterUnlockIds.veteran);
  });
}
