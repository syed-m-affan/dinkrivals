import 'player_side.dart';

enum RuleFault {
  outOfBounds,
  doubleBounce,
  twoBounceViolation,
  kitchenVolley,
  illegalServe,
}

class RuleResult {
  const RuleResult._({
    required this.pointEnded,
    this.winner,
    this.fault,
  });

  const RuleResult.continuePlay() : this._(pointEnded: false);

  const RuleResult.point({
    required PlayerSide winner,
    required RuleFault fault,
  }) : this._(
          pointEnded: true,
          winner: winner,
          fault: fault,
        );

  final bool pointEnded;
  final PlayerSide? winner;
  final RuleFault? fault;
}
