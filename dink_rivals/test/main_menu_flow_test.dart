import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/app/ad_provider.dart';
import 'package:dink_rivals/app/audio_provider.dart';
import 'package:dink_rivals/app/game_provider.dart';
import 'package:dink_rivals/app/haptics_provider.dart';
import 'package:dink_rivals/app/router.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/game/models/character_unlock.dart';
import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/services/audio_service.dart';
import 'package:dink_rivals/services/haptics_service.dart';
import 'package:dink_rivals/services/save_service.dart';

Future<({ProviderContainer container, FakeAdService ads, DinkRivalsGame game})>
    _pumpApp(
  WidgetTester tester, {
  SaveData saveData = const SaveData(),
}) async {
  SharedPreferences.setMockInitialValues({});
  final saveService = SaveService(await SharedPreferences.getInstance());
  final ads = FakeAdService();
  final game = DinkRivalsGame();
  final container = ProviderContainer(
    overrides: [
      dinkRivalsGameProvider.overrideWithValue(game),
      adServiceProvider.overrideWithValue(ads),
      adPlacementSystemProvider.overrideWithValue(AdPlacementSystem()),
      audioServiceProvider.overrideWithValue(FakeAudioService()),
      hapticsServiceProvider.overrideWithValue(FakeHapticsService()),
      saveServiceProvider.overrideWithValue(saveService),
      saveDataProvider.overrideWith(
        () => SaveDataNotifier(saveService, saveData),
      ),
    ],
  );
  addTearDown(container.dispose);

  final router = createAppRouter();
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();

  return (container: container, ads: ads, game: game);
}

void main() {
  testWidgets('new player reaches first match without a pre-game ad',
      (tester) async {
    final app = await _pumpApp(tester);

    expect(find.byKey(const Key('menu-quick-match')), findsOneWidget);
    expect(find.byKey(const Key('fake-banner-menu')), findsNothing);
    expect(app.ads.interstitialShows, 0);
    expect(app.ads.rewardedShows, 0);

    await tester.tap(find.byKey(const Key('menu-quick-match')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tutorial-title')), findsOneWidget);
    expect(find.byKey(const Key('fake-banner-menu')), findsNothing);
    expect(app.ads.interstitialShows, 0);
    expect(app.ads.rewardedShows, 0);
    expect(app.game.paused, isTrue);

    await tester.tap(find.byKey(const Key('tutorial-dismiss')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tutorial-title')), findsNothing);
    expect(app.game.paused, isFalse);
    expect(app.container.read(saveDataProvider).tutorialSeen, isTrue);
    expect(app.ads.interstitialShows, 0);
    expect(app.ads.rewardedShows, 0);
  });

  testWidgets('paused rival challenge can return to the main menu',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final app = await _pumpApp(
      tester,
      saveData: const SaveData(tutorialSeen: true),
    );

    await tester.tap(find.byKey(const Key('menu-roster')));
    await tester.pumpAndSettle();

    final challenge = find.byKey(
      const Key('roster-challenge-${CharacterUnlockIds.rallyQueen}'),
    );
    await tester.ensureVisible(challenge);
    await tester.tap(challenge);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('game-pause-button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('pause-menu')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const Key('menu-quick-match')), findsOneWidget);
    expect(app.game.paused, isFalse);
  });
}
