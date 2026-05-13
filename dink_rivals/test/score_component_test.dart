import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/components/rally_feedback_component.dart';
import 'package:dink_rivals/game/components/rally_strip_component.dart';
import 'package:dink_rivals/game/components/score_component.dart';
import 'package:dink_rivals/game/config/visual_palette.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/game/models/player_side.dart';
import 'package:dink_rivals/game/models/rule_result.dart';
import 'package:dink_rivals/game/models/shot_type.dart';

void main() {
  test('scoreboard serving indicator follows serving side', () {
    final game = DinkRivalsGame();
    final score = ScoreComponent(game);

    game.matchState.servingSide = PlayerSide.player;
    expect(score.servingIndicatorSideForTesting(), PlayerSide.player);

    game.matchState.servingSide = PlayerSide.opponent;
    expect(score.servingIndicatorSideForTesting(), PlayerSide.opponent);
    expect(score.scoreLabelForTesting(), '0 - 0');
  });

  test('rally strip exposes rally and last-shot readouts', () {
    final game = DinkRivalsGame();
    final strip = RallyStripComponent(game);

    game.matchState.rallyCount = 6;
    game.shotSystem.lastShotType = ShotType.dink;

    expect(strip.rallyLabelForTesting(), 'RALLY: 6');
    expect(strip.lastShotLabelForTesting(), 'LAST SHOT: DINK');
  });

  test('rally feedback maps shot labels to palette colors', () {
    expect(
      RallyFeedbackComponent.colorForFeedback('DINK'),
      VisualPalette.feedbackDink,
    );
    expect(
      RallyFeedbackComponent.colorForFeedback('DRIVE'),
      VisualPalette.feedbackDrive,
    );
    expect(
      RallyFeedbackComponent.colorForFeedback('LOB'),
      VisualPalette.feedbackLob,
    );
    expect(
      RallyFeedbackComponent.colorForFeedback('SMASH'),
      VisualPalette.feedbackSmash,
    );
    expect(
      RallyFeedbackComponent.colorForFeedback('FAULT: OUT'),
      VisualPalette.feedbackFault,
    );
  });

  test('rally feedback formats concept banner labels', () {
    expect(RallyFeedbackComponent.primaryTextFor('DINK'), 'DINK!');
    expect(RallyFeedbackComponent.secondaryTextFor('DINK'), 'NICE SHOT');
    expect(RallyFeedbackComponent.primaryTextFor('MISS'), 'MISS!');
    expect(
      RallyFeedbackComponent.secondaryTextFor('MISS'),
      'SWING MISSED',
    );
    expect(RallyFeedbackComponent.primaryTextFor('FAULT: OUT'), 'FAULT!');
    expect(RallyFeedbackComponent.secondaryTextFor('FAULT: OUT'), 'OUT');
    expect(RallyFeedbackComponent.bannerCenterYForSize(720), 104);
    expect(RallyFeedbackComponent.bannerCenterYForSize(915), 116);
  });

  test('point feedback remains visible after point reset', () async {
    final game = DinkRivalsGame();
    await game.onLoad();
    game.matchState.startPoint();

    game.awardPointForTesting(
      const RuleResult.point(
        winner: PlayerSide.player,
        fault: RuleFault.outOfBounds,
      ),
    );

    expect(game.matchState.pointInProgress, isFalse);
    expect(game.feedbackText, 'FAULT: OUT');
    expect(game.feedbackSeconds, greaterThan(0));
  });
}
