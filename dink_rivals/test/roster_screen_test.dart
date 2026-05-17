import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dink_rivals/app/audio_provider.dart';
import 'package:dink_rivals/game/models/character_unlock.dart';
import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/screens/roster_screen.dart';
import 'package:dink_rivals/services/audio_service.dart';
import 'package:dink_rivals/services/save_service.dart';

void main() {
  testWidgets('roster shows four portrait images', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final service = SaveService(await SharedPreferences.getInstance());
    final router = GoRouter(
      initialLocation: '/roster',
      routes: [
        GoRoute(
          path: '/roster',
          builder: (context, state) => const RosterScreen(),
        ),
        GoRoute(path: '/', builder: (context, state) => const SizedBox()),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(FakeAudioService()),
          saveServiceProvider.overrideWithValue(service),
          saveDataProvider.overrideWith(
            () => SaveDataNotifier(service, const SaveData()),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    expect(find.byType(Image), findsNWidgets(4));
    expect(find.byKey(const Key('roster-portrait-Rookie')), findsOneWidget);
    expect(
      find.byKey(const Key('roster-portrait-Rally Queen')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('roster-portrait-Veteran')), findsOneWidget);
    expect(find.byKey(const Key('roster-portrait-Showman')), findsOneWidget);
    expect(
      find.byKey(const Key('roster-unlock-${CharacterUnlockIds.rookie}')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('roster-unlock-${CharacterUnlockIds.showman}')),
      findsOneWidget,
    );
    expect(find.text('LOCKED'), findsWidgets);
  });
}
