import 'package:flutter/material.dart';

import '../game/config/visual_palette.dart';

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: VisualPalette.uiBackground,
      colorScheme: base.colorScheme.copyWith(
        primary: VisualPalette.playerPrimary,
        secondary: VisualPalette.feedbackDink,
        surface: VisualPalette.uiSurface,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: VisualPalette.textPrimary,
        displayColor: VisualPalette.textPrimary,
        fontFamily: 'monospace',
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'monospace',
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VisualPalette.uiAccent,
          foregroundColor: VisualPalette.textInverse,
          minimumSize: const Size(220, 56),
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
