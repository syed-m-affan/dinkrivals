import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/config/tournament_definitions.dart';

final rivalChallengeProvider =
    NotifierProvider<RivalChallengeNotifier, String?>(
  RivalChallengeNotifier.new,
);

class RivalChallengeNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void start(String rivalId) {
    TournamentDefinitions.byId(rivalId);
    state = rivalId;
  }

  void reset() {
    state = null;
  }

  TournamentRival? currentRival() {
    final id = state;
    return id == null ? null : TournamentDefinitions.byId(id);
  }
}
