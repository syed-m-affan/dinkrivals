import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/app/ad_provider.dart';
import 'package:dink_rivals/app/audio_provider.dart';
import 'package:dink_rivals/app/game_provider.dart';
import 'package:dink_rivals/app/haptics_provider.dart';
import 'package:dink_rivals/app/tournament_provider.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/game/models/tournament_state.dart';
import 'package:dink_rivals/screens/game_screen.dart';
import 'package:dink_rivals/screens/tournament_screen.dart';
import 'package:dink_rivals/services/audio_service.dart';
import 'package:dink_rivals/services/haptics_service.dart';
import 'package:dink_rivals/services/save_service.dart';

Future<ProviderContainer> _container(DinkRivalsGame game) async {
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
        () => SaveDataNotifier(service, const SaveData()),
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
  });
}
