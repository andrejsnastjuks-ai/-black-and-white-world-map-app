import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get dark {
    const seed = Color(0xFF26D07C);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
        surface: const Color(0xFF101214),
      ),
      scaffoldBackgroundColor: const Color(0xFF050607),
      cardTheme: CardTheme(
        color: const Color(0xFF111417),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(120, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      useMaterial3: true,
    );
  }
}
