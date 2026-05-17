import 'dart:io';

import 'package:dink_rivals/app/admob_config.dart';
import 'package:dink_rivals/app/app_config.dart';
import 'package:dink_rivals/app/game_provider.dart';
import 'package:dink_rivals/app/router.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('QA launch router accepts the end-match route', () {
    final router = createAppRouter(initialLocation: AppRoutes.endMatch);
    addTearDown(router.dispose);

    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutes.endMatch,
    );
  });

  test('QA launch router accepts the tournament route', () {
    final router = createAppRouter(initialLocation: AppRoutes.tournament);
    addTearDown(router.dispose);

    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutes.tournament,
    );
  });

  test('QA launch router accepts progression routes', () {
    final courtsRouter = createAppRouter(initialLocation: AppRoutes.courts);
    final trophyRouter = createAppRouter(initialLocation: AppRoutes.trophyRoom);
    addTearDown(courtsRouter.dispose);
    addTearDown(trophyRouter.dispose);

    expect(
        courtsRouter.routeInformationProvider.value.uri.path, AppRoutes.courts);
    expect(trophyRouter.routeInformationProvider.value.uri.path,
        AppRoutes.trophyRoom);
  });

  test('QA launch router falls back to menu for unknown routes', () {
    final router = createAppRouter(initialLocation: '/not-a-real-route');
    addTearDown(router.dispose);

    expect(router.routeInformationProvider.value.uri.path, AppRoutes.menu);
  });

  test('QA end-match seed is inactive unless explicitly enabled', () {
    final game = DinkRivalsGame();

    seedQaEndMatchForLaunch(game, enabled: false, winner: 'player');

    expect(game.matchState.matchOver, isFalse);
    expect(game.matchState.playerScore, 0);
    expect(game.matchState.opponentScore, 0);
  });

  test('QA end-match seed creates a completed match state', () {
    final game = DinkRivalsGame();

    seedQaEndMatchForLaunch(game, enabled: true, winner: 'player');

    expect(game.matchState.matchOver, isTrue);
    expect(game.matchState.playerScore, 11);
    expect(game.matchState.opponentScore, 6);
    expect(game.matchState.longestRally, 12);
  });

  test('Android manifest uses release-candidate launcher label', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(manifest, contains('android:label="Dink Rivals"'));
  });

  test('Android manifest uses a Gradle-provided AdMob app id placeholder', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(manifest, contains(r'android:value="${adMobApplicationId}"'));
    expect(gradle, contains('DINK_RIVALS_ADMOB_APP_ID'));
    expect(gradle, contains(AdMobConfig.androidTestAppId));
  });

  test('Android release signing falls back without credentials', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(gradle, contains('DINK_RIVALS_UPLOAD_STORE_FILE'));
    expect(gradle, contains('DINK_RIVALS_UPLOAD_STORE_PASSWORD'));
    expect(gradle, contains('DINK_RIVALS_UPLOAD_KEY_ALIAS'));
    expect(gradle, contains('DINK_RIVALS_UPLOAD_KEY_PASSWORD'));
    expect(
      gradle,
      contains('if (hasReleaseSigning) "release" else "debug"'),
    );
  });

  test('Android application id defaults to QA id and can be overridden', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    expect(gradle,
        contains('val defaultApplicationId = "com.example.dink_rivals"'));
    expect(gradle, contains('DINK_RIVALS_APPLICATION_ID'));
    expect(gradle, contains('applicationId = androidApplicationId'));
    expect(gradle, contains('namespace = "com.example.dink_rivals"'));
    expect(
      gradle,
      contains('applicationId is the install/Play identity'),
    );
  });

  test('release-candidate metadata is current and visible', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final menu = File('lib/screens/main_menu_screen.dart').readAsStringSync();

    expect(AppConfig.phaseLabel, 'MVP Release Candidate');
    expect(pubspec, contains('MVP release-candidate arcade pickleball game'));
    expect(menu, contains("Key('menu-phase-label')"));
    expect(menu, contains('AppConfig.phaseLabel'));
  });

  test('release preflight can run analyze tests build and production ad gate',
      () {
    final script = File('tool/release_readiness.ps1').readAsStringSync();

    expect(script, contains(r'[switch]$RunAnalyze'));
    expect(script, contains(r'[switch]$RunTests'));
    expect(script, contains(r'[switch]$BuildRelease'));
    expect(script, contains(r'[switch]$RequireProductionAdMode'));
    expect(script, contains('DINK_RIVALS_SHOW_AD_PLACEHOLDERS=false'));
    expect(script, contains('Flutter analyze'));
    expect(script, contains('Flutter tests'));
    expect(script, contains('Release build'));
  });
}
