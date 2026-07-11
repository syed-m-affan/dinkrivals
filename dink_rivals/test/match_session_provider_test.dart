import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/app/match_session_provider.dart';
import 'package:dink_rivals/game/config/tournament_definitions.dart';
import 'package:dink_rivals/game/models/match_session.dart';

void main() {
  test('challenge identity survives completion and rematch', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(matchSessionProvider.notifier);

    notifier.startRivalChallenge(TournamentDefinitions.veteran);
    notifier.complete(playerScore: 11, opponentScore: 8);

    final completed = container.read(matchSessionProvider).completed!;
    expect(completed.session.mode, MatchMode.rivalChallenge);
    expect(completed.session.opponentCharacterId, 'veteran');
    expect(completed.session.opponentProfile.id, 'veteran');

    final rematch = notifier.rematch();
    expect(rematch?.opponentCharacterId, 'veteran');
    expect(container.read(matchSessionProvider).completed, isNull);
  });

  test('classic cup sessions do not allow end-screen rematches', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(matchSessionProvider.notifier);
    notifier.startClassicCupMatch(
      TournamentDefinitions.showman,
      round: 'FINAL',
    );
    notifier.complete(playerScore: 11, opponentScore: 9);

    expect(notifier.rematch(), isNull);
  });

  test('clear removes active and completed identity', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(matchSessionProvider.notifier);
    notifier.startQuickMatch();
    notifier.complete(playerScore: 11, opponentScore: 5);
    notifier.clear();

    expect(container.read(matchSessionProvider).active, isNull);
    expect(container.read(matchSessionProvider).completed, isNull);
  });
}
