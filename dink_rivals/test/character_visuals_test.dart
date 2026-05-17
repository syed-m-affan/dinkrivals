import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:dink_rivals/game/config/character_visuals.dart';

void main() {
  test('all MVP roster characters have unique visual definitions', () {
    final visuals = CharacterVisuals.mvpRoster;

    expect(visuals.map((visual) => visual.displayName).toSet(), hasLength(4));
    expect(visuals.map((visual) => visual.id).toSet(), hasLength(4));
    expect(visuals.map((visual) => visual.portraitAsset).toSet(), hasLength(4));
    expect(visuals.map((visual) => visual.silhouetteNotes),
        everyElement(isNotEmpty));
    expect(
      visuals.map((visual) => visual.cosmeticOnlyNote),
      everyElement(contains('no stats or gameplay changes')),
    );
  });

  test('all MVP roster portrait and paddle asset paths exist', () {
    for (final visual in CharacterVisuals.mvpRoster) {
      expect(
        File(visual.portraitAsset).existsSync(),
        isTrue,
        reason: '${visual.displayName} portrait asset must exist',
      );
      expect(
        File(visual.paddleAsset).existsSync(),
        isTrue,
        reason: '${visual.displayName} paddle asset must exist',
      );
    }
  });

  test('display name lookup returns expected visual definition', () {
    expect(CharacterVisuals.byDisplayName('Rookie').id, 'rookie');
    expect(CharacterVisuals.byDisplayName('Rally Queen').id, 'rally_queen');
    expect(CharacterVisuals.byDisplayName('Veteran').id, 'veteran');
    expect(CharacterVisuals.byDisplayName('Showman').id, 'showman');
  });

  test('id lookup returns expected visual definition', () {
    expect(CharacterVisuals.byId('rookie').displayName, 'Rookie');
    expect(CharacterVisuals.byId('rally_queen').displayName, 'Rally Queen');
    expect(CharacterVisuals.byId('veteran').displayName, 'Veteran');
    expect(CharacterVisuals.byId('showman').displayName, 'Showman');
  });
}
