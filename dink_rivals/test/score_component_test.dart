import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/components/rally_feedback_component.dart';
import 'package:dink_rivals/game/components/score_component.dart';
import 'package:dink_rivals/game/config/visual_palette.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/game/models/player_side.dart';
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

  test('scoreboard exposes rally and last-shot readouts', () {
    final game = DinkRivalsGame();
    final score = ScoreComponent(game);

    game.rallyCount = 6;
    game.shotSystem.lastShotType = ShotType.dink;

    expect(score.rallyLabelForTesting(), 'RALLY: 6');
    expect(score.lastShotLabelForTesting(), 'LAST SHOT: DINK');
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
    expect(RallyFeedbackComponent.primaryTextFor('FAULT: OUT'), 'FAULT!');
    expect(RallyFeedbackComponent.secondaryTextFor('FAULT: OUT'), 'OUT');
    expect(RallyFeedbackComponent.bannerCenterYForSize(720), 104);
    expect(RallyFeedbackComponent.bannerCenterYForSize(915), 116);
  });
}
