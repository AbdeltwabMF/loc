import 'package:flutter/material.dart';

abstract final class LocTheme {
  static const _dark = Color(0xFF282828);
  static const _light = Color(0xFFFBF1C7);
  static const _yellow = Color(0xFFD79921);
  static const _orange = Color(0xFFD65D0E);
  static const _aqua = Color(0xFF689D6A);
  static const _red = Color(0xFFCC241D);

  static final light = _build(
    ColorScheme.fromSeed(
      seedColor: _yellow,
      surface: _light,
      error: _red,
    ).copyWith(
      primary: const Color(0xFF79740E),
      secondary: _aqua,
      tertiary: _orange,
      surfaceContainer: const Color(0xFFF2E5BC),
      surfaceContainerHigh: const Color(0xFFEBDBB2),
    ),
  );

  static final dark = _build(
    ColorScheme.fromSeed(
      seedColor: _yellow,
      brightness: Brightness.dark,
      surface: _dark,
      error: const Color(0xFFFB4934),
    ).copyWith(
      primary: const Color(0xFFFABD2F),
      secondary: const Color(0xFF8EC07C),
      tertiary: const Color(0xFFFE8019),
      surfaceContainer: const Color(0xFF3C3836),
      surfaceContainerHigh: const Color(0xFF504945),
    ),
  );

  static ThemeData _build(ColorScheme colors) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    );
    return ThemeData(
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: colors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainer,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colors.surfaceContainer,
        indicatorColor: colors.primaryContainer,
        height: 72,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.inverseSurface,
        contentTextStyle: TextStyle(color: colors.onInverseSurface),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4),
      ),
    );
  }
}
