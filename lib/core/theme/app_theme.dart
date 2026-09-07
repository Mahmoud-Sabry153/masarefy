import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'neon_colors.dart';

/// The single dark, neon-glow [ThemeData] used throughout Masarefy.
///
/// The app intentionally has only one theme (there's no "light mode"
/// toggle) — the neon-on-black look is the whole visual identity of the
/// app, so it lives here as one clearly-named, well-documented builder
/// rather than being duplicated across screens.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark();

    final colorScheme = base.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: NeonColors.primary,
      secondary: NeonColors.secondary,
      surface: NeonColors.surface,
      error: NeonColors.danger,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: NeonColors.textPrimary,
      onError: Colors.black,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: NeonColors.background,
      canvasColor: NeonColors.background,
      dividerColor: NeonColors.divider,
      splashFactory: InkRipple.splashFactory,
      textTheme: base.textTheme
          .apply(
            bodyColor: NeonColors.textPrimary,
            displayColor: NeonColors.textPrimary,
          )
          .copyWith(
            headlineSmall: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: NeonColors.textPrimary,
            ),
            titleLarge: const TextStyle(
              fontWeight: FontWeight.w600,
              color: NeonColors.textPrimary,
            ),
            bodyMedium: const TextStyle(color: NeonColors.textSecondary),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: NeonColors.textPrimary,
        titleTextStyle: TextStyle(
          color: NeonColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: NeonColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: NeonColors.divider),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: NeonColors.primary,
        foregroundColor: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NeonColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: NeonColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: NeonColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: NeonColors.primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: NeonColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeonColors.primary,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: NeonColors.primary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: NeonColors.surfaceElevated,
        contentTextStyle: const TextStyle(color: NeonColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: NeonColors.divider),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
