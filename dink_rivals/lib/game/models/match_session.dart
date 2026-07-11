import 'opponent_ai_profile.dart';

enum MatchMode {
  quickMatch,
  rivalChallenge,
  classicCup,
}

class MatchSession {
  const MatchSession({
    required this.mode,
    required this.opponentCharacterId,
    required this.opponentProfile,
    this.tournamentRound,
  });

  final MatchMode mode;
  final String opponentCharacterId;
  final OpponentAiProfile opponentProfile;
  final String? tournamentRound;

  bool get allowsRematch => mode != MatchMode.classicCup;
}

class CompletedMatchSummary {
  const CompletedMatchSummary({
    required this.session,
    required this.playerScore,
    required this.opponentScore,
    this.unlockedCharacterId,
  });

  final MatchSession session;
  final int playerScore;
  final int opponentScore;
  final String? unlockedCharacterId;

  bool get playerWon => playerScore > opponentScore;
}

class MatchSessionState {
  const MatchSessionState({this.active, this.completed});

  final MatchSession? active;
  final CompletedMatchSummary? completed;

  MatchSessionState copyWith({
    MatchSession? active,
    CompletedMatchSummary? completed,
    bool clearActive = false,
    bool clearCompleted = false,
  }) {
    return MatchSessionState(
      active: clearActive ? null : active ?? this.active,
      completed: clearCompleted ? null : completed ?? this.completed,
    );
  }
}
