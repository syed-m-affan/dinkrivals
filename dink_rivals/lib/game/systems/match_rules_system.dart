import '../config/court_constants.dart';
import '../models/ball_state.dart';
import '../models/player_side.dart';
import '../models/player_state.dart';
import '../models/rule_result.dart';
import 'ball_physics_system.dart';

class MatchRulesSystem {
  RuleResult evaluateGroundContact(BallState ball) {
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

    return const RuleResult.continuePlay();
  }

  RuleResult evaluatePhysicsResult({
    required BallState ball,
    required BallPhysicsResult physics,
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

    return const RuleResult.continuePlay();
  }

  RuleResult evaluateVolley({
    required PlayerState hitter,
    required BallState ball,
  }) {
    if (ball.z <= 0 || !_isInKitchen(hitter.side, hitter.position.y)) {
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
}
