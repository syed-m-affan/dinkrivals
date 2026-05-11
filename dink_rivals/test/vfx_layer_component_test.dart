import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/components/vfx/vfx_layer_component.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/game/models/player_side.dart';
import 'package:dink_rivals/game/models/player_state.dart';
import 'package:dink_rivals/game/models/shot_type.dart';
import 'package:dink_rivals/game/models/swing_intent.dart';

void main() {
  test('contact and bounce effects expire deterministically', () {
    final game = DinkRivalsGame();
    game.courtLayoutSystem.resize(Vector2(412, 915));
    final vfx = VfxLayerComponent(game);

    vfx.spawnContact(
      courtPosition: Vector2(110, 240),
      z: 20,
      shotType: ShotType.drive,
    );
    vfx.spawnBounce(courtPosition: Vector2(110, 260));

    expect(vfx.activeEffectCountForTesting, 2);

    vfx.update(0.1);
    expect(vfx.activeEffectCountForTesting, 2);

    vfx.update(0.2);
    expect(vfx.activeEffectCountForTesting, 0);
  });

  test('smash contact stays short enough to avoid sustained ball occlusion',
      () {
    final game = DinkRivalsGame();
    game.courtLayoutSystem.resize(Vector2(412, 915));
    final vfx = VfxLayerComponent(game);

    vfx.spawnContact(
      courtPosition: Vector2(110, 240),
      shotType: ShotType.smash,
    );

    vfx.update(0.12);
    expect(vfx.activeEffectCountForTesting, 1);

    vfx.update(0.05);
    expect(vfx.activeEffectCountForTesting, 0);
  });

  test('point burst uses the point burst sprite and expires', () {
    final game = DinkRivalsGame();
    game.courtLayoutSystem.resize(Vector2(412, 915));
    final vfx = VfxLayerComponent(game);

    vfx.spawnPointBurst(courtPosition: Vector2(100, 100));

    expect(vfx.activeEffectCountForTesting, 1);
    expect(vfx.activeSpriteNamesForTesting, contains('pointBurst'));

    vfx.update(0.43);
    expect(vfx.activeEffectCountForTesting, 0);
  });

  test('shot contact effects use distinct generated sprites', () {
    final game = DinkRivalsGame();
    game.courtLayoutSystem.resize(Vector2(412, 915));
    final vfx = VfxLayerComponent(game);

    vfx.spawnContact(
      courtPosition: Vector2(110, 240),
      shotType: ShotType.dink,
    );
    vfx.spawnContact(
      courtPosition: Vector2(110, 240),
      shotType: ShotType.drive,
      shotVelocity: Vector2(20, -80),
    );
    vfx.spawnContact(
      courtPosition: Vector2(110, 240),
      shotType: ShotType.lob,
    );
    vfx.spawnContact(
      courtPosition: Vector2(110, 240),
      shotType: ShotType.smash,
    );

    expect(
        vfx.activeSpriteNamesForTesting,
        containsAll([
          'dinkSpark',
          'driveArc',
          'lobArc',
          'smashBand',
        ]));
  });

  test('swing miss uses a short generated whiff effect', () {
    final game = DinkRivalsGame();
    game.courtLayoutSystem.resize(Vector2(412, 915));
    final vfx = VfxLayerComponent(game);

    vfx.spawnSwingMiss(
      hitter: PlayerState(
        position: Vector2(110, 370),
        side: PlayerSide.player,
      ),
      intent: SwingIntent.drive,
      swipeDirection: Vector2(1, 0),
    );

    expect(vfx.activeEffectCountForTesting, 1);
    expect(vfx.activeSpriteNamesForTesting, contains('missWhiff'));

    vfx.update(0.21);
    expect(vfx.activeEffectCountForTesting, 0);
  });

  test('effect list is capped to avoid persistent particle growth', () {
    final game = DinkRivalsGame();
    game.courtLayoutSystem.resize(Vector2(412, 915));
    final vfx = VfxLayerComponent(game);

    for (var i = 0; i < 25; i += 1) {
      vfx.spawnBounce(courtPosition: Vector2(100, 100 + i.toDouble()));
    }

    expect(vfx.activeEffectCountForTesting, 18);
  });

  test('ball trail samples are capped and clearable', () {
    final game = DinkRivalsGame();
    game.courtLayoutSystem.resize(Vector2(412, 915));
    final vfx = VfxLayerComponent(game);

    for (var i = 0; i < 20; i += 1) {
      vfx.addTrailSampleForTesting(Vector2(i.toDouble(), 10));
    }

    expect(vfx.activeTrailSampleCountForTesting, 12);

    vfx.clearBallTrail();
    expect(vfx.activeTrailSampleCountForTesting, 0);
  });

  test('contact and bounce clear the ball trail', () {
    final game = DinkRivalsGame();
    game.courtLayoutSystem.resize(Vector2(412, 915));
    final vfx = VfxLayerComponent(game);

    vfx.addTrailSampleForTesting(Vector2(12, 10));
    vfx.spawnContact(courtPosition: Vector2(110, 240));
    expect(vfx.activeTrailSampleCountForTesting, 0);

    vfx.addTrailSampleForTesting(Vector2(12, 10));
    vfx.spawnBounce(courtPosition: Vector2(110, 260));
    expect(vfx.activeTrailSampleCountForTesting, 0);
  });
}
