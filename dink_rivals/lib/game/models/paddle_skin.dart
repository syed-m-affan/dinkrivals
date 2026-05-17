import 'package:flutter/material.dart';

import '../config/visual_palette.dart';

class PaddleSkinDefinition {
  const PaddleSkinDefinition({
    required this.id,
    required this.displayName,
    required this.detail,
    required this.aimColor,
    required this.accentColor,
  });

  final String id;
  final String displayName;
  final String detail;
  final Color aimColor;
  final Color accentColor;
}

class PaddleSkinIds {
  static const classic = 'classic';
  static const dinkStreak = 'dink_streak';
  static const all = [classic, dinkStreak];

  static bool isKnown(String id) => all.contains(id);
}

class PaddleSkins {
  static const classic = PaddleSkinDefinition(
    id: PaddleSkinIds.classic,
    displayName: 'Classic Accent',
    detail: 'Default aim marker',
    aimColor: VisualPalette.feedbackFault,
    accentColor: VisualPalette.rookieSecondary,
  );

  static const dinkStreak = PaddleSkinDefinition(
    id: PaddleSkinIds.dinkStreak,
    displayName: 'Dink Streak Accent',
    detail: 'Recolors aim marker after five dinks',
    aimColor: VisualPalette.feedbackDink,
    accentColor: VisualPalette.uiAccent,
  );

  static const all = [classic, dinkStreak];

  static PaddleSkinDefinition byId(String id) {
    return all.firstWhere(
      (skin) => skin.id == id,
      orElse: () => classic,
    );
  }
}

String normalizedPaddleSkinId(String? id) {
  if (id == null || !PaddleSkinIds.isKnown(id)) {
    return PaddleSkinIds.classic;
  }
  return id;
}
