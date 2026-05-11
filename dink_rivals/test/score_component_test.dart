import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/components/rally_feedback_component.dart';
import 'package:dink_rivals/game/components/score_component.dart';
import 'package:dink_rivals/game/config/visual_palette.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/game/models/player_side.dart';

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
}
