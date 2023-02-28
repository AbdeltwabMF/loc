import 'package:flutter/material.dart';
import 'package:loc/themes/text_theme.dart';
import 'package:loc/themes/color_scheme.dart';

class LocThemeData {
  static ThemeData lightThemeData = themeData(lightColorScheme);
  static ThemeData darkThemeData = themeData(darkColorScheme);

  static ThemeData themeData(ColorScheme colorScheme) {
    return ThemeData(
      fontFamily: 'TiltNeon',
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        iconTheme: IconThemeData(
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      canvasColor: colorScheme.onSecondary,
      scaffoldBackgroundColor: colorScheme.background,
      highlightColor: Colors.transparent,
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: colorScheme.onSecondary,
          foregroundColor: colorScheme.secondary,
          side: BorderSide(
            color: colorScheme.outline,
            width: 1,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
      ),
    );
  }
}
