import '../config/court_constants.dart';
import '../models/ball_state.dart';
import '../models/match_state.dart';
import '../models/player_side.dart';
import '../models/player_state.dart';
import '../models/rule_result.dart';
import 'ball_physics_system.dart';

class MatchRulesSystem {
  RuleResult evaluateGroundContact(BallState ball, {MatchState? match}) {
    if (!_isInBounds(ball.x, ball.y)) {
      return RuleResult.point(
        winner: (ball.lastHitBy ?? ball.currentSide).opponent,
        fault: RuleFault.outOfBounds,
      );
    }

    if (ball.hasBouncedThisSide) {
      return RuleResult.point(
        winner: ball.currentSide.opponent,
        fault: RuleFault.doubleBounce,
      );
    }

    if (_isIllegalServeLanding(ball: ball, match: match)) {
      return RuleResult.point(
        winner: match!.servingSide.opponent,
        fault: RuleFault.illegalServe,
      );
    }

    return const RuleResult.continuePlay();
  }

  RuleResult evaluatePhysicsResult({
    required BallState ball,
    required BallPhysicsResult physics,
    MatchState? match,
  }) {
    if (!physics.groundContact) {
      return const RuleResult.continuePlay();
    }

    // Double bounce is checked before out-of-bounds: once the receiver has
    // failed to return a legally-bounced ball, the rally is already won by
    // the hitter, regardless of where the ball ends up on its second bounce.
    if (physics.wasDoubleBounce) {
      return RuleResult.point(
        winner: ball.currentSide.opponent,
        fault: RuleFault.doubleBounce,
      );
    }

    if (physics.landedOutOfBounds) {
      return RuleResult.point(
        winner: (ball.lastHitBy ?? ball.currentSide).opponent,
        fault: RuleFault.outOfBounds,
      );
    }

    if (_isIllegalServeLanding(ball: ball, match: match)) {
      return RuleResult.point(
        winner: match!.servingSide.opponent,
        fault: RuleFault.illegalServe,
      );
    }

    return const RuleResult.continuePlay();
  }

  RuleResult evaluateVolley({
    required PlayerState hitter,
    required BallState ball,
    MatchState? match,
  }) {
    if (ball.z <= 0) {
      return const RuleResult.continuePlay();
    }

    if (match != null &&
        match.pointInProgress &&
        !match.twoBounceRuleSatisfied &&
        !match.hasCourtBounce(hitter.side)) {
      return RuleResult.point(
        winner: hitter.side.opponent,
        fault: RuleFault.twoBounceViolation,
      );
    }

    if (!_isInKitchen(hitter.side, hitter.position.y)) {
      return const RuleResult.continuePlay();
    }

    return RuleResult.point(
      winner: hitter.side.opponent,
      fault: RuleFault.kitchenVolley,
    );
  }

  bool _isInBounds(double x, double y) {
    return x >= Court.left &&
        x <= Court.right &&
        y >= Court.top &&
        y <= Court.bottom;
  }

  bool _isInKitchen(PlayerSide side, double y) {
    if (side == PlayerSide.player) {
      return y >= Court.playerKitchenTopY && y <= Court.playerKitchenBottomY;
    }
    return y >= Court.opponentKitchenTopY && y <= Court.opponentKitchenBottomY;
  }

  bool _isIllegalServeLanding({
    required BallState ball,
    required MatchState? match,
  }) {
    if (match == null ||
        !match.pointInProgress ||
        match.hasAnyCourtBounceThisPoint ||
        ball.lastHitBy != match.servingSide) {
      return false;
    }
    return !_isInLegalServeCourt(
      server: match.servingSide,
      serverScore: match.servingSide == PlayerSide.player
          ? match.playerScore
          : match.opponentScore,
      x: ball.x,
      y: ball.y,
    );
  }

  bool _isInLegalServeCourt({
    required PlayerSide server,
    required int serverScore,
    required double x,
    required double y,
  }) {
    if (!_isInBounds(x, y)) {
      return false;
    }

    final targetLeftHalf =
        server == PlayerSide.player ? serverScore.isEven : serverScore.isOdd;
    final inTargetHalf =
        targetLeftHalf ? x <= Court.width / 2 : x >= Court.width / 2;
    if (!inTargetHalf) {
      return false;
    }

    if (server == PlayerSide.player) {
      return y >= Court.top && y < Court.opponentKitchenTopY;
    }
    return y > Court.playerKitchenBottomY && y <= Court.bottom;
  }
}
