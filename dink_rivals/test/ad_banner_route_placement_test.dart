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
import 'package:dink_rivals/game/models/save_data.dart';
import 'package:dink_rivals/services/audio_service.dart';
import 'package:dink_rivals/services/save_service.dart';
import 'package:dink_rivals/widgets/ad_banner_slot.dart';

Future<void> _pumpRoute(
  WidgetTester tester, {
  required String route,
}) async {
  SharedPreferences.setMockInitialValues({});
  final saveService = SaveService(await SharedPreferences.getInstance());
  final router = createAppRouter(initialLocation: route);
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dinkRivalsGameProvider.overrideWithValue(DinkRivalsGame()),
        adServiceProvider.overrideWithValue(FakeAdService()),
        adPlacementSystemProvider.overrideWithValue(AdPlacementSystem()),
        audioServiceProvider.overrideWithValue(FakeAudioService()),
        hapticsServiceProvider.overrideWithValue(FakeHapticsService()),
        saveServiceProvider.overrideWithValue(saveService),
        saveDataProvider.overrideWith(
          () => SaveDataNotifier(
            saveService,
            const SaveData(matchesCompleted: 1, tutorialSeen: true),
          ),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
}

Finder _fakeBannerWidgets() {
  return find.byWidgetPredicate((widget) {
    final key = widget.key;
    return key is ValueKey<String> && key.value.startsWith('fake-banner-');
  });
}

void main() {
  const allowedPlacements = <String, String>{
    AppRoutes.menu: 'menu',
    AppRoutes.settings: 'settings',
    AppRoutes.roster: 'roster',
    AppRoutes.trophyRoom: 'trophy-room',
  };

  for (final entry in allowedPlacements.entries) {
    testWidgets('route ${entry.key} mounts its guarded banner slot',
        (tester) async {
      await _pumpRoute(tester, route: entry.key);

      expect(find.byType(AdBannerSlot), findsOneWidget);
      expect(find.byKey(Key('fake-banner-${entry.value}')), findsOneWidget);
      expect(_fakeBannerWidgets(), findsOneWidget);
    });
  }

  const blockedRoutes = <String>[
    AppRoutes.game,
    AppRoutes.debugRally,
    AppRoutes.courts,
    AppRoutes.tournament,
    AppRoutes.endMatch,
  ];

  for (final route in blockedRoutes) {
    testWidgets('route $route does not mount a banner slot', (tester) async {
      await _pumpRoute(tester, route: route);

      expect(find.byType(AdBannerSlot), findsNothing);
      expect(_fakeBannerWidgets(), findsNothing);
    });
  }
}
