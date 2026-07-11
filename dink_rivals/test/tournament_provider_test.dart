import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/app/tournament_provider.dart';
import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/game/models/character_unlock.dart';
import 'package:dink_rivals/game/models/tournament_state.dart';
import 'package:dink_rivals/services/save_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('championship records a persisted Classic Cup trophy', () async {
    final prefs = await SharedPreferences.getInstance();
    final saveService = SaveService(prefs);
    final container = ProviderContainer(
      overrides: [
        saveServiceProvider.overrideWithValue(saveService),
        saveDataProvider.overrideWith(
          () => SaveDataNotifier(saveService, const SaveData()),
        ),
      ],
    );
    addTearDown(container.dispose);

    final tournament = container.read(tournamentProvider.notifier);
    tournament.startClassicCup();
    await tournament.recordCompletedMatch(playerScore: 11, opponentScore: 7);
    await tournament.recordCompletedMatch(playerScore: 11, opponentScore: 9);

    expect(
        container.read(tournamentProvider).status, TournamentStatus.champion);
    expect(container.read(saveDataProvider).classicCupWins, 1);
    expect(
      container
          .read(saveDataProvider)
          .isCharacterUnlocked(CharacterUnlockIds.showman),
      isTrue,
    );
    expect(
      container.read(tournamentProvider).championshipRewardWasNew,
      isTrue,
    );
    final reloaded = await SaveService(prefs).load();
    expect(reloaded.classicCupTrophyUnlocked, isTrue);
    expect(reloaded.isCharacterUnlocked(CharacterUnlockIds.showman), isTrue);
  });

  test('semifinal loss does not unlock trophy', () async {
    final prefs = await SharedPreferences.getInstance();
    final saveService = SaveService(prefs);
    final container = ProviderContainer(
      overrides: [
        saveServiceProvider.overrideWithValue(saveService),
        saveDataProvider.overrideWith(
          () => SaveDataNotifier(saveService, const SaveData()),
        ),
      ],
    );
    addTearDown(container.dispose);

    final tournament = container.read(tournamentProvider.notifier);
    tournament.startClassicCup();
    await tournament.recordCompletedMatch(playerScore: 8, opponentScore: 11);

    expect(
      container.read(tournamentProvider).status,
      TournamentStatus.eliminated,
    );
    expect(container.read(saveDataProvider).classicCupWins, 0);
  });

  test('retryEliminatedMatch restores bracket without trophy unlock', () async {
    final prefs = await SharedPreferences.getInstance();
    final saveService = SaveService(prefs);
    final container = ProviderContainer(
      overrides: [
        saveServiceProvider.overrideWithValue(saveService),
        saveDataProvider.overrideWith(
          () => SaveDataNotifier(saveService, const SaveData()),
        ),
      ],
    );
    addTearDown(container.dispose);

    final tournament = container.read(tournamentProvider.notifier);
    tournament.startClassicCup();
    await tournament.recordCompletedMatch(playerScore: 8, opponentScore: 11);
    tournament.retryEliminatedMatch();

    expect(
        container.read(tournamentProvider).status, TournamentStatus.semifinal);
    expect(container.read(tournamentProvider).completedMatches, isEmpty);
    expect(container.read(saveDataProvider).classicCupWins, 0);
  });
}
