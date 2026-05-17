import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/app/ad_provider.dart';
import 'package:dink_rivals/app/audio_provider.dart';
import 'package:dink_rivals/app/game_provider.dart';
import 'package:dink_rivals/app/haptics_provider.dart';
import 'package:dink_rivals/app/rival_challenge_provider.dart';
import 'package:dink_rivals/app/tournament_provider.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/game/models/character_unlock.dart';
import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/game/models/tournament_state.dart';
import 'package:dink_rivals/screens/game_screen.dart';
import 'package:dink_rivals/screens/tournament_screen.dart';
import 'package:dink_rivals/services/audio_service.dart';
import 'package:dink_rivals/services/haptics_service.dart';
import 'package:dink_rivals/services/save_service.dart';

Future<ProviderContainer> _container(
  DinkRivalsGame game, {
  SaveData initialSaveData = const SaveData(tutorialSeen: true),
}) async {
  SharedPreferences.setMockInitialValues({});
  final service = SaveService(await SharedPreferences.getInstance());
  return ProviderContainer(
    overrides: [
      dinkRivalsGameProvider.overrideWithValue(game),
      adServiceProvider.overrideWithValue(FakeAdService()),
      adPlacementSystemProvider.overrideWithValue(AdPlacementSystem()),
      audioServiceProvider.overrideWithValue(FakeAudioService()),
      hapticsServiceProvider.overrideWithValue(FakeHapticsService()),
      saveServiceProvider.overrideWithValue(service),
      saveDataProvider.overrideWith(
        () => SaveDataNotifier(service, initialSaveData),
      ),
    ],
  );
}

Widget _wrap(ProviderContainer container) {
  final router = GoRouter(
    initialLocation: '/game',
    routes: [
      GoRoute(path: '/game', builder: (context, state) => const GameScreen()),
      GoRoute(
        path: '/tournament',
        builder: (context, state) => const TournamentScreen(),
      ),
      GoRoute(
        path: '/end-match',
        builder: (context, state) => const Text('end'),
      ),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets(
      'completed tournament match advances bracket instead of end match',
      (tester) async {
    final game = DinkRivalsGame();
    final container = await _container(game);
    addTearDown(container.dispose);
    container.read(tournamentProvider.notifier).startClassicCup();

    await tester.pumpWidget(_wrap(container));
    await tester.pump();

    game.matchState
      ..playerScore = 11
      ..opponentScore = 7;
    game.matchOverNotifier.value = true;
    await tester.pumpAndSettle();

    expect(find.byType(TournamentScreen), findsOneWidget);
    expect(
        container.read(tournamentProvider).status, TournamentStatus.finalRound);
    expect(container.read(saveDataProvider).matchesCompleted, 1);
    expect(container.read(saveDataProvider).stars, 100);
  });

  testWidgets('first game visit shows and persists quick-start tutorial',
      (tester) async {
    final game = DinkRivalsGame();
    final container = await _container(game, initialSaveData: const SaveData());
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container));
    await tester.pump();

    expect(find.byKey(const Key('tutorial-title')), findsOneWidget);
    expect(game.paused, isTrue);

    await tester.tap(find.byKey(const Key('tutorial-dismiss')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tutorial-title')), findsNothing);
    expect(game.paused, isFalse);
    expect(container.read(saveDataProvider).tutorialSeen, isTrue);
  });

  testWidgets('winning tournament final unlocks defeated rival',
      (tester) async {
    final game = DinkRivalsGame();
    final container = await _container(game);
    addTearDown(container.dispose);
    final tournament = container.read(tournamentProvider.notifier);
    tournament.startClassicCup();
    await tournament.recordCompletedMatch(playerScore: 11, opponentScore: 7);

    await tester.pumpWidget(_wrap(container));
    await tester.pump();

    game.matchState
      ..playerScore = 11
      ..opponentScore = 9;
    game.matchOverNotifier.value = true;
    await tester.pumpAndSettle();

    expect(
        container.read(saveDataProvider).isCharacterUnlocked(
              CharacterUnlockIds.showman,
            ),
        isTrue);
  });

  testWidgets('winning rival challenge unlocks challenged character',
      (tester) async {
    final game = DinkRivalsGame();
    final container = await _container(game);
    addTearDown(container.dispose);
    container
        .read(rivalChallengeProvider.notifier)
        .start(CharacterUnlockIds.veteran);

    await tester.pumpWidget(_wrap(container));
    await tester.pump();

    game.matchState
      ..playerScore = 11
      ..opponentScore = 8;
    game.matchOverNotifier.value = true;
    await tester.pumpAndSettle();

    expect(find.text('end'), findsOneWidget);
    expect(
        container.read(saveDataProvider).isCharacterUnlocked(
              CharacterUnlockIds.veteran,
            ),
        isTrue);
    expect(container.read(rivalChallengeProvider), isNull);
  });

  testWidgets('winning Rally Queen challenge unlocks Rally Queen',
      (tester) async {
    final game = DinkRivalsGame();
    final container = await _container(game);
    addTearDown(container.dispose);
    container
        .read(rivalChallengeProvider.notifier)
        .start(CharacterUnlockIds.rallyQueen);

    await tester.pumpWidget(_wrap(container));
    await tester.pump();

    game.matchState
      ..playerScore = 11
      ..opponentScore = 8;
    game.matchOverNotifier.value = true;
    await tester.pumpAndSettle();

    expect(
        container.read(saveDataProvider).isCharacterUnlocked(
              CharacterUnlockIds.rallyQueen,
            ),
        isTrue);
    expect(container.read(rivalChallengeProvider), isNull);
  });
}
