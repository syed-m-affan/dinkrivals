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

  void resetPoint({bool keepRallyStats = false}) {
    if (!keepRallyStats) {
      rallyCount = 0;
    }
    pointInProgress = false;
  }

  void startPoint() {
    pointInProgress = true;
    rallyCount = 0;
  }
}
