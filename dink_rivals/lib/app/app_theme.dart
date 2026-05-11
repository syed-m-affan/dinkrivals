import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF101218),
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF4AA3FF),
        secondary: const Color(0xFF4FD08B),
        surface: const Color(0xFF1A1D26),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4AA3FF),
          foregroundColor: Colors.white,
          minimumSize: const Size(220, 56),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
