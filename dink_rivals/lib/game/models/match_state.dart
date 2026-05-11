import 'player_side.dart';

class MatchState {
  MatchState({
    this.playerScore = 0,
    this.opponentScore = 0,
    this.servingSide = PlayerSide.player,
    this.pointInProgress = false,
    this.matchOver = false,
    this.rallyCount = 0,
    this.playerDinkContactsThisMatch = 0,
    this.playerSmashContactsThisMatch = 0,
    this.longestRally = 0,
    this.playerCourtBouncedThisPoint = false,
    this.opponentCourtBouncedThisPoint = false,
  });

  int playerScore;
  int opponentScore;
  PlayerSide servingSide;
  bool pointInProgress;
  bool matchOver;
  int rallyCount;
  int playerDinkContactsThisMatch;
  int playerSmashContactsThisMatch;
  int longestRally;
  bool playerCourtBouncedThisPoint;
  bool opponentCourtBouncedThisPoint;

  bool get hasAnyCourtBounceThisPoint =>
      playerCourtBouncedThisPoint || opponentCourtBouncedThisPoint;

  bool get twoBounceRuleSatisfied =>
      playerCourtBouncedThisPoint && opponentCourtBouncedThisPoint;

  bool hasCourtBounce(PlayerSide side) {
    return side == PlayerSide.player
        ? playerCourtBouncedThisPoint
        : opponentCourtBouncedThisPoint;
  }

  void recordGroundBounce(PlayerSide side) {
    if (side == PlayerSide.player) {
      playerCourtBouncedThisPoint = true;
    } else {
      opponentCourtBouncedThisPoint = true;
    }
  }

  void clearPointBounceState() {
    playerCourtBouncedThisPoint = false;
    opponentCourtBouncedThisPoint = false;
  }

  void resetPoint({bool keepRallyStats = false}) {
    if (!keepRallyStats) {
      rallyCount = 0;
    }
    pointInProgress = false;
    clearPointBounceState();
  }

  void startPoint() {
    pointInProgress = true;
    rallyCount = 0;
    clearPointBounceState();
  }
}
