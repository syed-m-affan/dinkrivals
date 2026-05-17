import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/app/ad_provider.dart';
import 'package:dink_rivals/app/audio_provider.dart';
import 'package:dink_rivals/app/game_provider.dart';
import 'package:dink_rivals/game/config/character_visuals.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/game/models/character_unlock.dart';
import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/screens/end_match_screen.dart';
import 'package:dink_rivals/services/audio_service.dart';
import 'package:dink_rivals/services/save_service.dart';

Future<Widget> _wrap(
  DinkRivalsGame game, {
  FakeAdService? adService,
  AdPlacementSystem? adPlacement,
  SaveData initialSaveData = const SaveData(),
}) async {
  SharedPreferences.setMockInitialValues({});
  final saveService = SaveService(await SharedPreferences.getInstance());
  final router = GoRouter(
    initialLocation: '/end-match',
    routes: [
      GoRoute(
        path: '/end-match',
        builder: (context, state) => const EndMatchScreen(),
      ),
      GoRoute(
          path: '/', builder: (context, state) => const _StubScreen('menu')),
      GoRoute(
          path: '/game',
          builder: (context, state) => const _StubScreen('game')),
    ],
  );
  return ProviderScope(
    overrides: [
      dinkRivalsGameProvider.overrideWithValue(game),
      adServiceProvider.overrideWithValue(adService ?? FakeAdService()),
      audioServiceProvider.overrideWithValue(FakeAudioService()),
      adPlacementSystemProvider
          .overrideWithValue(adPlacement ?? AdPlacementSystem()),
      saveServiceProvider.overrideWithValue(saveService),
      saveDataProvider.overrideWith(
        () => SaveDataNotifier(saveService, initialSaveData),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

class _NativeInterstitialFakeService extends FakeAdService {
  @override
  bool get usesNativeInterstitialUi => true;
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

class _StubScreen extends StatelessWidget {
  const _StubScreen(this.label);
  final String label;
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('stub-$label')));
}

void main() {
  testWidgets('player win shows YOU WIN with scores and rally stats',
      (tester) async {
    final game = DinkRivalsGame();
    game.matchState.playerScore = 7;
    game.matchState.opponentScore = 4;
    game.matchState.rallyCount = 12;
    game.matchState.longestRally = 19;

    await tester.pumpWidget(await _wrap(game));
    await tester.pump();

    expect(find.text('YOU WIN'), findsOneWidget);
    final portrait = tester
        .widget<Image>(find.byKey(const Key('end-match-winner-portrait')));
    final image = portrait.image as AssetImage;
    expect(
      image.assetName,
      CharacterVisuals.byId(CharacterUnlockIds.defaultSelected).portraitAsset,
    );
    expect(find.text('7'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('19'), findsOneWidget);
  });

  testWidgets('opponent win shows OPPONENT WINS', (tester) async {
    final game = DinkRivalsGame();
    game.matchState.playerScore = 5;
    game.matchState.opponentScore = 7;

    await tester.pumpWidget(await _wrap(game));
    await tester.pump();

    expect(find.text('OPPONENT WINS'), findsOneWidget);
    final portrait = tester
        .widget<Image>(find.byKey(const Key('end-match-winner-portrait')));
    final image = portrait.image as AssetImage;
    expect(image.assetName, CharacterVisuals.gameplayOpponent.portraitAsset);
  });

  testWidgets('tied fallback does not declare an opponent win', (tester) async {
    final game = DinkRivalsGame();
    game.matchState.playerScore = 0;
    game.matchState.opponentScore = 0;

    await tester.pumpWidget(await _wrap(game));
    await tester.pump();

    expect(find.text('MATCH COMPLETE'), findsOneWidget);
    expect(find.text('OPPONENT WINS'), findsNothing);
  });

  testWidgets('rematch and menu buttons are present', (tester) async {
    final game = DinkRivalsGame();
    game.matchState.playerScore = 7;
    game.matchState.opponentScore = 3;

    await tester.pumpWidget(await _wrap(game));
    await tester.pump();

    expect(find.byKey(const Key('end-match-rematch')), findsOneWidget);
    expect(find.byKey(const Key('end-match-menu')), findsOneWidget);
  });

  testWidgets('rewarded ad is optional and grants placeholder reward',
      (tester) async {
    final game = DinkRivalsGame();
    game.matchState.playerScore = 7;
    game.matchState.opponentScore = 3;
    final adService = FakeAdService();

    await tester.pumpWidget(await _wrap(game, adService: adService));
    await tester.pump();

    expect(find.text('MATCH REWARD 100'), findsOneWidget);
    expect(adService.rewardedShows, 0);

    await tester.ensureVisible(find.byKey(const Key('end-match-rewarded-ad')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('end-match-rewarded-ad')));
    await tester.pump();

    expect(adService.rewardedShows, 1);
    expect(find.text('REWARD CLAIMED 2X'), findsOneWidget);
    expect(find.text('STARS 100'), findsOneWidget);
  });

  testWidgets('return to menu skips interstitial before eligibility',
      (tester) async {
    final game = DinkRivalsGame();
    game.matchState.playerScore = 7;
    game.matchState.opponentScore = 3;
    final adService = FakeAdService();

    await tester.pumpWidget(await _wrap(game, adService: adService));
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('end-match-menu')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('end-match-menu')));
    await tester.pumpAndSettle();

    expect(adService.interstitialShows, 0);
    expect(find.text('stub-menu'), findsOneWidget);
  });

  testWidgets('eligible return to menu shows fake interstitial then navigates',
      (tester) async {
    final game = DinkRivalsGame();
    game.matchState.playerScore = 7;
    game.matchState.opponentScore = 3;
    final adService = FakeAdService();
    final adPlacement = AdPlacementSystem()
      ..advance(AdPlacementSystem.minTimeBetweenInterstitials);
    for (var i = 0; i < 3; i++) {
      adPlacement.recordMatchCompleted();
    }

    await tester.pumpWidget(
      await _wrap(game, adService: adService, adPlacement: adPlacement),
    );
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('end-match-menu')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('end-match-menu')));
    await tester.pump();

    expect(adService.interstitialShows, 1);
    expect(find.byKey(const Key('fake-interstitial-dialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('fake-interstitial-close')));
    await tester.pumpAndSettle();

    expect(find.text('stub-menu'), findsOneWidget);
    expect(adPlacement.matchesSinceInterstitial, 0);
  });

  testWidgets('failed return-to-menu interstitial keeps cadence',
      (tester) async {
    final game = DinkRivalsGame();
    game.matchState.playerScore = 7;
    game.matchState.opponentScore = 3;
    final adService = _FailingInterstitialFakeService();
    final adPlacement = AdPlacementSystem()
      ..advance(AdPlacementSystem.minTimeBetweenInterstitials);
    for (var i = 0; i < 3; i++) {
      adPlacement.recordMatchCompleted();
    }

    await tester.pumpWidget(
      await _wrap(game, adService: adService, adPlacement: adPlacement),
    );
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('end-match-menu')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('end-match-menu')));
    await tester.pumpAndSettle();

    expect(adService.interstitialShows, 1);
    expect(adService.lastInterstitialPlacement, 'return_to_menu');
    expect(find.byKey(const Key('fake-interstitial-dialog')), findsNothing);
    expect(find.text('stub-menu'), findsOneWidget);
    expect(adPlacement.matchesSinceInterstitial, 3);
    expect(
      adPlacement.timeSinceInterstitial,
      AdPlacementSystem.minTimeBetweenInterstitials,
    );
  });

  testWidgets('native interstitial service skips fake dialog', (tester) async {
    final game = DinkRivalsGame();
    game.matchState.playerScore = 7;
    game.matchState.opponentScore = 3;
    final adService = _NativeInterstitialFakeService();
    final adPlacement = AdPlacementSystem()
      ..advance(AdPlacementSystem.minTimeBetweenInterstitials);
    for (var i = 0; i < 3; i++) {
      adPlacement.recordMatchCompleted();
    }

    await tester.pumpWidget(
      await _wrap(game, adService: adService, adPlacement: adPlacement),
    );
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('end-match-menu')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('end-match-menu')));
    await tester.pumpAndSettle();

    expect(adService.interstitialShows, 1);
    expect(find.byKey(const Key('fake-interstitial-dialog')), findsNothing);
    expect(find.text('stub-menu'), findsOneWidget);
  });

  testWidgets('rematch does not trigger interstitial', (tester) async {
    final game = DinkRivalsGame();
    game.matchState.playerScore = 7;
    game.matchState.opponentScore = 3;
    final adService = FakeAdService();
    final adPlacement = AdPlacementSystem()
      ..advance(AdPlacementSystem.minTimeBetweenInterstitials);
    for (var i = 0; i < 3; i++) {
      adPlacement.recordMatchCompleted();
    }

    await tester.pumpWidget(
      await _wrap(game, adService: adService, adPlacement: adPlacement),
    );
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('end-match-rematch')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('end-match-rematch')));
    await tester.pumpAndSettle();

    expect(adService.interstitialShows, 0);
    expect(find.text('stub-game'), findsOneWidget);
  });
}
