import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/app/ad_provider.dart';
import 'package:dink_rivals/app/audio_provider.dart';
import 'package:dink_rivals/app/game_provider.dart';
import 'package:dink_rivals/app/tournament_provider.dart';
import 'package:dink_rivals/game/config/tournament_definitions.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/screens/tournament_screen.dart';
import 'package:dink_rivals/services/audio_service.dart';
import 'package:dink_rivals/services/save_service.dart';

Future<ProviderContainer> _container(
  DinkRivalsGame game, {
  FakeAdService? adService,
  AdPlacementSystem? adPlacement,
}) async {
  SharedPreferences.setMockInitialValues({});
  final service = SaveService(await SharedPreferences.getInstance());
  return ProviderContainer(
    overrides: [
      dinkRivalsGameProvider.overrideWithValue(game),
      adServiceProvider.overrideWithValue(adService ?? FakeAdService()),
      adPlacementSystemProvider
          .overrideWithValue(adPlacement ?? AdPlacementSystem()),
      audioServiceProvider.overrideWithValue(FakeAudioService()),
      saveServiceProvider.overrideWithValue(service),
      saveDataProvider.overrideWith(
        () => SaveDataNotifier(service, const SaveData()),
      ),
    ],
  );
}

Widget _wrap(ProviderContainer container) {
  final router = GoRouter(
    initialLocation: '/tournament',
    routes: [
      GoRoute(
        path: '/tournament',
        builder: (context, state) => const TournamentScreen(),
      ),
      GoRoute(path: '/game', builder: (context, state) => const Text('game')),
      GoRoute(path: '/', builder: (context, state) => const Text('menu')),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  );
}

class _FailingInterstitialFakeService extends FakeAdService {
  @override
  Future<bool> maybeShowInterstitial({required String placement}) async {
    if (!await isInterstitialReady()) {
      return false;
    }
    interstitialShows++;
    lastInterstitialPlacement = placement;
    return false;
  }
}

void main() {
  testWidgets('tournament screen starts a Classic Cup run', (tester) async {
    final container = await _container(DinkRivalsGame());
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container));
    await tester.pump();

    expect(find.byKey(const Key('tournament-title')), findsOneWidget);
    expect(find.text('Classic Cup Trophy locked'), findsOneWidget);
    expect(find.byKey(const Key('tournament-start')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tournament-start')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tournament-play-match')), findsOneWidget);
    expect(find.textContaining('YOU  VS  Rally Queen'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
  });

  testWidgets('play match configures rival profile and navigates to game',
      (tester) async {
    final game = DinkRivalsGame();
    final container = await _container(game);
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container));
    container.read(tournamentProvider.notifier).startClassicCup();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tournament-play-match')));
    await tester.pumpAndSettle();

    expect(find.text('game'), findsOneWidget);
    expect(
      game.opponentAiSystem.profile.id,
      TournamentDefinitions.rallyQueen.id,
    );
  });

  testWidgets('championship state shows unlocked trophy', (tester) async {
    final container = await _container(DinkRivalsGame());
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container));
    final tournament = container.read(tournamentProvider.notifier);
    tournament.startClassicCup();
    await tournament.recordCompletedMatch(playerScore: 11, opponentScore: 7);
    await tournament.recordCompletedMatch(playerScore: 11, opponentScore: 9);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tournament-trophy-label')), findsOneWidget);
    expect(find.text('Classic Cup Trophy unlocked'), findsNWidgets(2));
    expect(find.text('WINS 1'), findsOneWidget);
    expect(find.byKey(const Key('tournament-result-panel')), findsOneWidget);
    expect(find.text('CHAMPION'), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('tournament-result-score')))
          .data,
      '11-9',
    );
    expect(find.byKey(const Key('tournament-restart')), findsOneWidget);
  });

  testWidgets('eliminated player can watch retry ad to replay failed match',
      (tester) async {
    final adService = FakeAdService();
    final container = await _container(DinkRivalsGame(), adService: adService);
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container));
    final tournament = container.read(tournamentProvider.notifier);
    tournament.startClassicCup();
    await tournament.recordCompletedMatch(playerScore: 8, opponentScore: 11);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tournament-result-panel')), findsOneWidget);
    expect(find.text('ELIMINATED IN SEMIFINAL'), findsOneWidget);
    expect(find.text('Lost to Rally Queen'), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('tournament-result-score')))
          .data,
      '8-11',
    );
    expect(find.byKey(const Key('tournament-retry-ad')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('tournament-retry-ad')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('tournament-retry-ad')));
    await tester.pumpAndSettle();

    expect(adService.rewardedShows, 1);
    expect(find.byKey(const Key('tournament-play-match')), findsOneWidget);
    expect(find.textContaining('YOU  VS  Rally Queen'), findsOneWidget);
  });

  testWidgets('eligible tournament exit shows fake interstitial before menu',
      (tester) async {
    final adService = FakeAdService();
    final adPlacement = AdPlacementSystem()
      ..advance(AdPlacementSystem.minTimeBetweenInterstitials);
    for (var i = 0; i < 3; i++) {
      adPlacement.recordMatchCompleted();
    }
    final container = await _container(
      DinkRivalsGame(),
      adService: adService,
      adPlacement: adPlacement,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container));
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('tournament-menu')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('tournament-menu')));
    await tester.pump();

    expect(adService.interstitialShows, 1);
    expect(find.byKey(const Key('fake-interstitial-dialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('fake-interstitial-close')));
    await tester.pumpAndSettle();

    expect(find.text('menu'), findsOneWidget);
    expect(adPlacement.matchesSinceInterstitial, 0);
  });

  testWidgets('failed tournament exit interstitial keeps cadence',
      (tester) async {
    final adService = _FailingInterstitialFakeService();
    final adPlacement = AdPlacementSystem()
      ..advance(AdPlacementSystem.minTimeBetweenInterstitials);
    for (var i = 0; i < 3; i++) {
      adPlacement.recordMatchCompleted();
    }
    final container = await _container(
      DinkRivalsGame(),
      adService: adService,
      adPlacement: adPlacement,
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container));
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('tournament-menu')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('tournament-menu')));
    await tester.pumpAndSettle();

    expect(adService.interstitialShows, 1);
    expect(adService.lastInterstitialPlacement, 'exit_tournament');
    expect(find.byKey(const Key('fake-interstitial-dialog')), findsNothing);
    expect(find.text('menu'), findsOneWidget);
    expect(adPlacement.matchesSinceInterstitial, 3);
    expect(
      adPlacement.timeSinceInterstitial,
      AdPlacementSystem.minTimeBetweenInterstitials,
    );
  });
}
