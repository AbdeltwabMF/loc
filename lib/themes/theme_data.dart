import 'package:flutter/material.dart';
import 'package:loc/themes/text_theme.dart';
import 'package:loc/themes/color_scheme.dart';

class LocThemeData {
  static ThemeData lightThemeData = themeData(lightColorScheme);
  static ThemeData darkThemeData = themeData(darkColorScheme);

  static ThemeData themeData(ColorScheme colorScheme) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
        ),
      ),
      colorScheme: colorScheme,
      canvasColor: colorScheme.onSecondary,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
      ),
      fontFamily: 'TiltNeon',
      highlightColor: Colors.transparent,
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      scaffoldBackgroundColor: colorScheme.background,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.alphaBlend(
          GruvboxDarkPalette.bg2,
          GruvboxDarkPalette.bg,
        ),
        contentTextStyle: textTheme.titleMedium!.apply(
          color: GruvboxDarkPalette.bg,
        ),
      ),
      textTheme: textTheme,
      useMaterial3: true,
    );
  }
}
