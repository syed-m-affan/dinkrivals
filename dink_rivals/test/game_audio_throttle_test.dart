import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/game/models/player_side.dart';
import 'package:dink_rivals/game/models/rule_result.dart';
import 'package:dink_rivals/services/audio_service.dart';
import 'package:dink_rivals/services/haptics_service.dart';

void main() {
  test('point and fault feedback is rate limited during rapid awards',
      () async {
    final audio = FakeAudioService();
    final haptics = FakeHapticsService();
    final game = DinkRivalsGame(
      audioService: audio,
      hapticsService: haptics,
    );
    await game.onLoad();

    game.setElapsedSecondsForTesting(1);
    game.awardPointForTesting(
      const RuleResult.point(
        winner: PlayerSide.player,
        fault: RuleFault.outOfBounds,
      ),
    );
    game.awardPointForTesting(
      const RuleResult.point(
        winner: PlayerSide.player,
        fault: RuleFault.outOfBounds,
      ),
    );

    expect(audio.faultCalls, 1);
    expect(audio.pointCalls, 1);
    expect(haptics.mediumCalls, 1);

    game.setElapsedSecondsForTesting(1.30);
    game.awardPointForTesting(
      const RuleResult.point(
        winner: PlayerSide.player,
        fault: RuleFault.outOfBounds,
      ),
    );

    expect(audio.faultCalls, 2);
    expect(audio.pointCalls, 2);
    expect(haptics.mediumCalls, 2);
  });
}
