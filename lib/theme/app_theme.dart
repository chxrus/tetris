import 'package:flutter/material.dart';
import 'game_palette.dart';

class AppTheme {
  static ThemeData fromPalette(GamePalette palette) {
    final bool isDark = palette.gameBackground.computeLuminance() < 0.5;

    final ColorScheme base = isDark
        ? ColorScheme.dark(
            surface: palette.gameBackground,
            onSurface: palette.hudTextPrimary,
            primary: const Color(0xFF4DD0E1),
            onPrimary: Colors.black,
            secondary: const Color(0xFF9575CD),
            onSecondary: Colors.white,
            error: const Color(0xFFEF5350),
            onError: Colors.white,
          )
        : ColorScheme.light(
            surface: palette.gameBackground,
            onSurface: palette.hudTextPrimary,
            primary: const Color(0xFF4DD0E1),
            onPrimary: Colors.black,
            secondary: const Color(0xFF9575CD),
            onSecondary: Colors.white,
            error: const Color(0xFFEF5350),
            onError: Colors.white,
          );

    final ColorScheme cs = base.copyWith(
      tertiary: palette.previewFrame,
      outline: palette.hudTextSecondary.withValues(alpha: 0.40),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: palette.gameBackground,
      textTheme: const TextTheme().apply(
        bodyColor: palette.hudTextPrimary,
        displayColor: palette.hudTextPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: palette.hudTextSecondary.withValues(alpha: 0.60)),
          foregroundColor: cs.onSurface,
        ),
      ),
      dividerColor: palette.hudTextSecondary.withValues(alpha: 0.20),
    );
  }
}
