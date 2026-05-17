import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/app/audio_provider.dart';
import 'package:dink_rivals/app/game_provider.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/game/models/court_unlock.dart';
import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/screens/court_select_screen.dart';
import 'package:dink_rivals/screens/trophy_room_screen.dart';
import 'package:dink_rivals/services/audio_service.dart';
import 'package:dink_rivals/services/save_service.dart';

Future<ProviderContainer> _container(
  DinkRivalsGame game,
  SaveData saveData,
) async {
  SharedPreferences.setMockInitialValues({});
  final service = SaveService(await SharedPreferences.getInstance());
  return ProviderContainer(
    overrides: [
      dinkRivalsGameProvider.overrideWithValue(game),
      audioServiceProvider.overrideWithValue(FakeAudioService()),
      saveServiceProvider.overrideWithValue(service),
      saveDataProvider.overrideWith(
        () => SaveDataNotifier(service, saveData),
      ),
    ],
  );
}

Widget _wrap(ProviderContainer container, {required String initialLocation}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/trophy-room',
        builder: (context, state) => const TrophyRoomScreen(),
      ),
      GoRoute(
        path: '/courts',
        builder: (context, state) => const CourtSelectScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const Text('menu')),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('trophy room shows persistent stars and unlock states',
      (tester) async {
    final container = await _container(
      DinkRivalsGame(),
      const SaveData(stars: 250, classicCupWins: 1, tutorialSeen: true),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container, initialLocation: '/trophy-room'));
    await tester.pump();

    expect(find.byKey(const Key('trophy-room-stars')), findsOneWidget);
    expect(find.text('250'), findsOneWidget);
    expect(find.text('Classic Cup wins: 1'), findsOneWidget);
    expect(find.text('Seen'), findsOneWidget);
  });

  testWidgets('trophy room shows dink streak paddle achievement',
      (tester) async {
    final container = await _container(
      DinkRivalsGame(),
      const SaveData(dinkStreakPaddleUnlocked: true),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container, initialLocation: '/trophy-room'));
    await tester.pump();

    expect(find.byKey(const Key('trophy-room-dink-streak-paddle-title')),
        findsOneWidget);
    expect(find.text('Dink Streak Paddle'), findsOneWidget);
    expect(find.text('Five dink contacts in one match'), findsOneWidget);
  });

  testWidgets('court screen selects cosmetic court and updates game',
      (tester) async {
    final game = DinkRivalsGame();
    final container = await _container(game, const SaveData());
    addTearDown(container.dispose);

    await tester.pumpWidget(_wrap(container, initialLocation: '/courts'));
    await tester.pump();

    expect(find.byKey(const Key('court-park_court-state')), findsOneWidget);
    expect(find.text('SELECTED'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('court-${CourtUnlockIds.training}-select')),
    );
    await tester.pumpAndSettle();

    expect(container.read(saveDataProvider).activeCourtId,
        CourtUnlockIds.training);
    expect(game.selectedCourtId, CourtUnlockIds.training);
    expect(find.text('CURRENT COURT'), findsOneWidget);
  });
}
