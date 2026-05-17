import 'package:flutter/material.dart';

import 'visual_palette.dart';

class CharacterVisualDefinition {
  const CharacterVisualDefinition({
    required this.id,
    required this.displayName,
    required this.portraitAsset,
    required this.primaryColor,
    required this.secondaryColor,
    required this.paddleAsset,
    required this.paddleColor,
    required this.silhouetteNotes,
  });

  final String id;
  final String displayName;
  final String portraitAsset;
  final Color primaryColor;
  final Color secondaryColor;
  final String paddleAsset;
  final Color paddleColor;
  final String silhouetteNotes;

  String get cosmeticOnlyNote =>
      'Cosmetic visual definition only; no stats or gameplay changes.';
}

class CharacterVisuals {
  static const rookie = CharacterVisualDefinition(
    id: 'rookie',
    displayName: 'Rookie',
    portraitAsset: 'assets/images/ui/portrait_rookie.png',
    primaryColor: VisualPalette.rookiePrimary,
    secondaryColor: VisualPalette.rookieSecondary,
    paddleAsset: 'assets/images/sprites/paddle_player.png',
    paddleColor: VisualPalette.playerPaddle,
    silhouetteNotes: 'Balanced compact stance with a simple cap-like top read.',
  );

  static const rallyQueen = CharacterVisualDefinition(
    id: 'rally_queen',
    displayName: 'Rally Queen',
    portraitAsset: 'assets/images/ui/portrait_rally_queen.png',
    primaryColor: VisualPalette.rallyQueenPrimary,
    secondaryColor: VisualPalette.rallyQueenSecondary,
    paddleAsset: 'assets/images/sprites/paddle_player.png',
    paddleColor: VisualPalette.rallyQueenPrimary,
    silhouetteNotes:
        'Upright control-player posture with a brighter headband read.',
  );

  static const veteran = CharacterVisualDefinition(
    id: 'veteran',
    displayName: 'Veteran',
    portraitAsset: 'assets/images/ui/portrait_veteran.png',
    primaryColor: VisualPalette.veteranPrimary,
    secondaryColor: VisualPalette.veteranSecondary,
    paddleAsset: 'assets/images/sprites/paddle_player.png',
    paddleColor: VisualPalette.veteranPrimary,
    silhouetteNotes:
        'Steady defensive stance with broader shoulders and muted kit.',
  );

  static const showman = CharacterVisualDefinition(
    id: 'showman',
    displayName: 'Showman',
    portraitAsset: 'assets/images/ui/portrait_showman.png',
    primaryColor: VisualPalette.showmanPrimary,
    secondaryColor: VisualPalette.showmanSecondary,
    paddleAsset: 'assets/images/sprites/paddle_opponent.png',
    paddleColor: VisualPalette.showmanPrimary,
    silhouetteNotes: 'Louder attacking pose with high-contrast accents.',
  );

  static const gameplayPlayer = rallyQueen;
  static const gameplayOpponent = rookie;

  static const List<CharacterVisualDefinition> mvpRoster = [
    rookie,
    rallyQueen,
    veteran,
    showman,
  ];

  static CharacterVisualDefinition byDisplayName(String displayName) {
    return mvpRoster.firstWhere(
      (visual) => visual.displayName == displayName,
      orElse: () => throw ArgumentError.value(
        displayName,
        'displayName',
        'No character visual definition exists for this roster name.',
      ),
    );
  }

  static CharacterVisualDefinition byId(String id) {
    return mvpRoster.firstWhere(
      (visual) => visual.id == id,
      orElse: () => throw ArgumentError.value(
        id,
        'id',
        'No character visual definition exists for this ID.',
      ),
    );
  }
}
