import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:dink_rivals/app/game_provider.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/screens/end_match_screen.dart';

Widget _wrap(DinkRivalsGame game) {
  final router = GoRouter(
    initialLocation: '/end-match',
    routes: [
      GoRoute(
        path: '/end-match',
        builder: (context, state) => const EndMatchScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const _StubScreen('menu')),
      GoRoute(
          path: '/game', builder: (context, state) => const _StubScreen('game')),
    ],
  );
  return ProviderScope(
    overrides: [
      dinkRivalsGameProvider.overrideWithValue(game),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
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

    await tester.pumpWidget(_wrap(game));
    await tester.pump();

    expect(find.text('YOU WIN'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('19'), findsOneWidget);
  });

  testWidgets('opponent win shows OPPONENT WINS', (tester) async {
    final game = DinkRivalsGame();
    game.matchState.playerScore = 5;
    game.matchState.opponentScore = 7;

    await tester.pumpWidget(_wrap(game));
    await tester.pump();

    expect(find.text('OPPONENT WINS'), findsOneWidget);
  });

  testWidgets('rematch and menu buttons are present', (tester) async {
    final game = DinkRivalsGame();
    game.matchState.playerScore = 7;
    game.matchState.opponentScore = 3;

    await tester.pumpWidget(_wrap(game));
    await tester.pump();

    expect(find.byKey(const Key('end-match-rematch')), findsOneWidget);
    expect(find.byKey(const Key('end-match-menu')), findsOneWidget);
  });
}
