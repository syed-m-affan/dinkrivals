enum TournamentStatus {
  idle,
  semifinal,
  finalRound,
  champion,
  eliminated,
}

class TournamentMatchRecord {
  const TournamentMatchRecord({
    required this.roundName,
    required this.opponentId,
    required this.opponentName,
    required this.playerScore,
    required this.opponentScore,
  });

  final String roundName;
  final String opponentId;
  final String opponentName;
  final int playerScore;
  final int opponentScore;

  bool get playerWon => playerScore > opponentScore;

  @override
  bool operator ==(Object other) {
    return other is TournamentMatchRecord &&
        other.roundName == roundName &&
        other.opponentId == opponentId &&
        other.opponentName == opponentName &&
        other.playerScore == playerScore &&
        other.opponentScore == opponentScore;
  }

  @override
  int get hashCode => Object.hash(
        roundName,
        opponentId,
        opponentName,
        playerScore,
        opponentScore,
      );
}

class TournamentState {
  const TournamentState({
    this.status = TournamentStatus.idle,
    this.currentOpponentId,
    this.currentOpponentName,
    this.completedMatches = const [],
  });

  final TournamentStatus status;
  final String? currentOpponentId;
  final String? currentOpponentName;
  final List<TournamentMatchRecord> completedMatches;

  bool get isActive =>
      status == TournamentStatus.semifinal ||
      status == TournamentStatus.finalRound;

  bool get isComplete =>
      status == TournamentStatus.champion ||
      status == TournamentStatus.eliminated;

  bool get playerWonCup => status == TournamentStatus.champion;

  String get currentRoundName {
    return switch (status) {
      TournamentStatus.semifinal => 'Semifinal',
      TournamentStatus.finalRound => 'Final',
      TournamentStatus.champion => 'Champion',
      TournamentStatus.eliminated => 'Eliminated',
      TournamentStatus.idle => 'Not started',
    };
  }

  TournamentState copyWith({
    TournamentStatus? status,
    Object? currentOpponentId = _sentinel,
    Object? currentOpponentName = _sentinel,
    List<TournamentMatchRecord>? completedMatches,
  }) {
    return TournamentState(
      status: status ?? this.status,
      currentOpponentId: currentOpponentId == _sentinel
          ? this.currentOpponentId
          : currentOpponentId as String?,
      currentOpponentName: currentOpponentName == _sentinel
          ? this.currentOpponentName
          : currentOpponentName as String?,
      completedMatches: completedMatches ?? this.completedMatches,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TournamentState &&
        other.status == status &&
        other.currentOpponentId == currentOpponentId &&
        other.currentOpponentName == currentOpponentName &&
        _listEquals(other.completedMatches, completedMatches);
  }

  @override
  int get hashCode => Object.hash(
        status,
        currentOpponentId,
        currentOpponentName,
        Object.hashAll(completedMatches),
      );
}

const Object _sentinel = Object();

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) {
    return true;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i += 1) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}
