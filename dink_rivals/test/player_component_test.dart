import 'dart:io';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/components/opponent_component.dart';
import 'package:dink_rivals/game/components/player_component.dart';
import 'package:dink_rivals/game/dink_rivals_game.dart';
import 'package:dink_rivals/game/models/shot_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('player animation switches between idle run and swing', () {
    final game = DinkRivalsGame();
    final component = PlayerComponent(game);

    expect(component.currentPoseNameForTesting(), 'idle');

    game.matchState.startPoint();
    expect(component.currentPoseNameForTesting(), 'idle');

    component.state.velocity = Vector2(20, 0);
    component.update(0.016);
    expect(component.currentPoseNameForTesting(), 'run');

    component.state.isSwinging = true;
    component.update(0.016);
    expect(component.currentPoseNameForTesting(), 'swing');
  });

  test('opponent animation switches between idle run and swing', () {
    final game = DinkRivalsGame();
    final component = OpponentComponent(game);

    expect(component.currentPoseNameForTesting(), 'idle');

    game.matchState.startPoint();
    expect(component.currentPoseNameForTesting(), 'idle');

    component.state.velocity = Vector2(0, 20);
    component.update(0.016);
    expect(component.currentPoseNameForTesting(), 'run');

    component.state.isSwinging = true;
    component.update(0.016);
    expect(component.currentPoseNameForTesting(), 'swing');
  });

  test('opponent run animation plays while player is preparing serve', () {
    final game = DinkRivalsGame();
    final component = OpponentComponent(game);

    expect(game.matchState.pointInProgress, isFalse);

    component.state.velocity = Vector2(0, 20);
    component.update(0.016);

    expect(component.currentPoseNameForTesting(), 'run');
  });

  test('opponent renders slightly larger for far-court readability', () {
    expect(OpponentComponent.visualScaleFor(0.7), closeTo(0.938, 0.0001));
  });

  test('shot swing poses use distinct visual leans', () {
    expect(
      PlayerComponent.swingLeanForShotForTesting(ShotType.dink),
      isNot(PlayerComponent.swingLeanForShotForTesting(ShotType.drive)),
    );
    expect(
      PlayerComponent.swingLeanForShotForTesting(ShotType.lob),
      isNot(PlayerComponent.swingLeanForShotForTesting(ShotType.smash)),
    );
    expect(
      OpponentComponent.swingLeanForShotForTesting(ShotType.drive),
      isNot(OpponentComponent.swingLeanForShotForTesting(ShotType.smash)),
    );
  });

  test('shot-specific generated character sheets are checked in', () {
    const files = [
      'assets/images/sprites/player_dink.png',
      'assets/images/sprites/player_drive.png',
      'assets/images/sprites/player_lob.png',
      'assets/images/sprites/player_smash.png',
      'assets/images/sprites/opponent_dink.png',
      'assets/images/sprites/opponent_drive.png',
      'assets/images/sprites/opponent_lob.png',
      'assets/images/sprites/opponent_smash.png',
    ];

    for (final file in files) {
      expect(File(file).existsSync(), isTrue, reason: '$file must exist');
    }
  });

  test('shot types select shot-specific animation poses', () {
    final game = DinkRivalsGame();
    final player = PlayerComponent(game);
    final opponent = OpponentComponent(game);

    for (final entry in {
      ShotType.dink: 'dink',
      ShotType.drive: 'drive',
      ShotType.lob: 'lob',
      ShotType.smash: 'smash',
    }.entries) {
      player.state
        ..lastShotType = entry.key
        ..isSwinging = true;
      opponent.state
        ..lastShotType = entry.key
        ..isSwinging = true;

      player.update(0.016);
      opponent.update(0.016);

      expect(player.currentPoseNameForTesting(), entry.value);
      expect(opponent.currentPoseNameForTesting(), entry.value);
    }
  });

  test('hit confirm keeps the same character model after swing pose expires',
      () {
    final game = DinkRivalsGame();
    final component = PlayerComponent(game);
    game.matchState.startPoint();

    component.state.isSwinging = true;
    component.showHitConfirm();
    component.update(0.016);
    expect(component.currentPoseNameForTesting(), 'swing');

    component.update(0.18);
    expect(component.currentPoseNameForTesting(), 'hitConfirm');
  });

  test('point result switches to win and loss poses', () {
    final game = DinkRivalsGame();
    final player = PlayerComponent(game);
    final opponent = OpponentComponent(game);
    game.matchState.startPoint();

    player.showPointResult(player.state.side);
    opponent.showPointResult(player.state.side);

    expect(player.currentPoseNameForTesting(), 'pointWin');
    expect(opponent.currentPoseNameForTesting(), 'pointLoss');

    player.update(0.73);
    opponent.update(0.73);
    expect(player.currentPoseNameForTesting(), 'idle');
    expect(opponent.currentPoseNameForTesting(), 'idle');
  });

  test('point result clears queued hit confirm and shows result pose', () {
    final game = DinkRivalsGame();
    final component = PlayerComponent(game);
    game.matchState.startPoint();

    component.showHitConfirm();
    component.showPointResult(component.state.side);

    expect(component.currentPoseNameForTesting(), 'pointWin');
  });

  test('sprite frame count follows actual sheet width', () async {
    final game = DinkRivalsGame();
    final player = PlayerComponent(game);
    final opponent = OpponentComponent(game);

    final playerDrive =
        await _loadImage('assets/images/sprites/player_drive.png');
    final playerRun = await _loadImage('assets/images/sprites/player_run.png');
    final opponentSmash =
        await _loadImage('assets/images/sprites/opponent_smash.png');

    expect(player.frameCountForTesting(playerDrive), 1);
    expect(player.frameCountForTesting(playerRun), 2);
    expect(opponent.frameCountForTesting(opponentSmash), 1);
  });

  test('character facing follows horizontal movement direction', () {
    final game = DinkRivalsGame();
    final player = PlayerComponent(game);
    final opponent = OpponentComponent(game);

    expect(player.facingXForTesting(), 1);
    player.state.velocity = Vector2(-20, 0);
    player.update(0.016);
    expect(player.facingXForTesting(), -1);
    player.state.velocity = Vector2(20, 0);
    player.update(0.016);
    expect(player.facingXForTesting(), 1);

    expect(opponent.facingXForTesting(), -1);
    opponent.state.velocity = Vector2(20, 0);
    opponent.update(0.016);
    expect(opponent.facingXForTesting(), 1);
  });
}

Future<ui.Image> _loadImage(String path) async {
  final data = await rootBundle.load(path);
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  return frame.image;
}
