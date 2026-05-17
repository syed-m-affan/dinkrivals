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
}
