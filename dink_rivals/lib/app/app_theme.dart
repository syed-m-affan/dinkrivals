import 'package:flutter/material.dart';

import '../game/config/visual_palette.dart';

class ArcadeUiTokens {
  static const double radius = 6;
  static const double borderWidth = 3;
  static const double innerHighlightWidth = 2;
  static const EdgeInsets panelPadding = EdgeInsets.all(16);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 14,
  );
  static const BorderRadius borderRadius = BorderRadius.all(
    Radius.circular(radius),
  );
  static const TextStyle labelTextStyle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );
  static const TextStyle titleTextStyle = TextStyle(
    fontFamily: 'monospace',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );
  static const List<BoxShadow> panelShadow = [
    BoxShadow(
      color: Color(0x66000000),
      offset: Offset(0, 4),
      blurRadius: 0,
    ),
  ];
}

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
      cardTheme: const CardThemeData(
        color: VisualPalette.uiSurface,
        shadowColor: Color(0x66000000),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: ArcadeUiTokens.borderRadius,
        ),
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
          shape: const RoundedRectangleBorder(
            borderRadius: ArcadeUiTokens.borderRadius,
          ),
        ),
      ),
    );
  }
}
