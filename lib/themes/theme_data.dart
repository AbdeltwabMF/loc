import 'package:flutter/material.dart';

abstract final class Gruvbox {
  static const light = GruvboxPalette(
    bg: Color(0xFFFBF1C7),
    fg: Color(0xFF3C3836),
    redSoft: Color(0xFFCC241D),
    redHard: Color(0xFF9D0006),
    greenSoft: Color(0xFF98971A),
    greenHard: Color(0xFF79740E),
    yellowSoft: Color(0xFFD79921),
    yellowHard: Color(0xFFB57614),
    blueSoft: Color(0xFF458588),
    blueHard: Color(0xFF076678),
    purpleSoft: Color(0xFFB16286),
    purpleHard: Color(0xFF8F3F71),
    aquaSoft: Color(0xFF689D6A),
    aquaHard: Color(0xFF427B58),
    grayHard: Color(0xFF7C6F64),
    graySoft: Color(0xFF928374),
    orangeSoft: Color(0xFFD65D0E),
    orangeHard: Color(0xFFAF3A03),
    bg0H: Color(0xFFF9F5D7),
    bg0: Color(0xFFFBF1C7),
    bg0S: Color(0xFFF2E5BC),
    bg1: Color(0xFFEBDBB2),
    bg2: Color(0xFFD5C4A1),
    bg3: Color(0xFFBDAE93),
    bg4: Color(0xFFA89984),
    fg0: Color(0xFF282828),
    fg1: Color(0xFF3C3836),
    fg2: Color(0xFF504945),
    fg3: Color(0xFF665C54),
    fg4: Color(0xFF7C6F64),
  );

  static const dark = GruvboxPalette(
    bg: Color(0xFF282828),
    fg: Color(0xFFEBDBB2),
    redSoft: Color(0xFFCC241D),
    redHard: Color(0xFFFB4934),
    greenSoft: Color(0xFF98971A),
    greenHard: Color(0xFFB8BB26),
    yellowSoft: Color(0xFFD79921),
    yellowHard: Color(0xFFFABD2F),
    blueSoft: Color(0xFF458588),
    blueHard: Color(0xFF83A598),
    purpleSoft: Color(0xFFB16286),
    purpleHard: Color(0xFFD3869B),
    aquaSoft: Color(0xFF689D6A),
    aquaHard: Color(0xFF8EC07C),
    grayHard: Color(0xFFA89984),
    graySoft: Color(0xFF928374),
    orangeSoft: Color(0xFFD65D0E),
    orangeHard: Color(0xFFFE8019),
    bg0H: Color(0xFF1D2021),
    bg0: Color(0xFF282828),
    bg0S: Color(0xFF32302F),
    bg1: Color(0xFF3C3836),
    bg2: Color(0xFF504945),
    bg3: Color(0xFF665C54),
    bg4: Color(0xFF7C6F64),
    fg0: Color(0xFFFBF1C7),
    fg1: Color(0xFFEBDBB2),
    fg2: Color(0xFFD5C4A1),
    fg3: Color(0xFFBDAE93),
    fg4: Color(0xFFA89984),
  );
}

class GruvboxPalette {
  const GruvboxPalette({
    required this.bg,
    required this.fg,
    required this.redSoft,
    required this.redHard,
    required this.greenSoft,
    required this.greenHard,
    required this.yellowSoft,
    required this.yellowHard,
    required this.blueSoft,
    required this.blueHard,
    required this.purpleSoft,
    required this.purpleHard,
    required this.aquaSoft,
    required this.aquaHard,
    required this.graySoft,
    required this.grayHard,
    required this.orangeSoft,
    required this.orangeHard,
    required this.bg0H,
    required this.bg0,
    required this.bg0S,
    required this.bg1,
    required this.bg2,
    required this.bg3,
    required this.bg4,
    required this.fg0,
    required this.fg1,
    required this.fg2,
    required this.fg3,
    required this.fg4,
  });

  final Color bg;
  final Color fg;
  final Color redSoft;
  final Color redHard;
  final Color greenSoft;
  final Color greenHard;
  final Color yellowSoft;
  final Color yellowHard;
  final Color blueSoft;
  final Color blueHard;
  final Color purpleSoft;
  final Color purpleHard;
  final Color aquaSoft;
  final Color aquaHard;
  final Color graySoft;
  final Color grayHard;
  final Color orangeSoft;
  final Color orangeHard;
  final Color bg0H;
  final Color bg0;
  final Color bg0S;
  final Color bg1;
  final Color bg2;
  final Color bg3;
  final Color bg4;
  final Color fg0;
  final Color fg1;
  final Color fg2;
  final Color fg3;
  final Color fg4;
}

abstract final class AppTheme {
  static final themeLight = _build(
    ColorScheme(
      brightness: Brightness.light,
      primary: Gruvbox.light.purpleHard,
      onPrimary: Gruvbox.light.bg,
      primaryContainer: Gruvbox.light.bg,
      onPrimaryContainer: Gruvbox.light.fg0,
      secondary: Gruvbox.light.aquaSoft,
      onSecondary: Gruvbox.light.bg,
      secondaryContainer: Gruvbox.light.bg1,
      onSecondaryContainer: Gruvbox.light.fg0,
      tertiary: Gruvbox.light.blueHard,
      onTertiary: Gruvbox.light.bg,
      tertiaryContainer: Gruvbox.light.bg2,
      onTertiaryContainer: Gruvbox.light.fg0,
      error: Gruvbox.light.redSoft,
      onError: Gruvbox.light.bg,
      errorContainer: Gruvbox.light.redHard,
      onErrorContainer: Gruvbox.light.bg,
      surface: Gruvbox.light.bg,
      onSurface: Gruvbox.light.fg0,
      surfaceContainerLowest: Gruvbox.light.bg0H,
      surfaceContainerLow: Gruvbox.light.bg0,
      surfaceContainer: Gruvbox.light.bg0S,
      surfaceContainerHigh: Gruvbox.light.bg1,
      surfaceContainerHighest: Gruvbox.light.bg2,
      onSurfaceVariant: Gruvbox.light.fg2,
      outline: Gruvbox.light.graySoft,
      outlineVariant: Gruvbox.light.bg3,
      shadow: Gruvbox.light.fg0,
      scrim: Gruvbox.light.fg0,
      inverseSurface: Gruvbox.light.fg0,
      onInverseSurface: Gruvbox.light.bg,
      inversePrimary: Gruvbox.dark.purpleHard,
      surfaceTint: Gruvbox.light.purpleHard,
    ),
  );

  static final themeDark = _build(
    ColorScheme(
      brightness: Brightness.dark,
      primary: Gruvbox.dark.purpleHard,
      onPrimary: Gruvbox.dark.bg,
      primaryContainer: Gruvbox.dark.bg,
      onPrimaryContainer: Gruvbox.dark.fg0,
      secondary: Gruvbox.dark.aquaSoft,
      onSecondary: Gruvbox.dark.fg,
      secondaryContainer: Gruvbox.dark.bg1,
      onSecondaryContainer: Gruvbox.dark.fg0,
      tertiary: Gruvbox.dark.blueHard,
      onTertiary: Gruvbox.dark.bg,
      tertiaryContainer: Gruvbox.dark.bg2,
      onTertiaryContainer: Gruvbox.dark.fg0,
      error: Gruvbox.dark.redSoft,
      onError: Gruvbox.dark.fg,
      errorContainer: Gruvbox.dark.redHard,
      onErrorContainer: Gruvbox.dark.fg0,
      surface: Gruvbox.dark.bg,
      onSurface: Gruvbox.dark.fg0,
      surfaceContainerLowest: Gruvbox.dark.bg0H,
      surfaceContainerLow: Gruvbox.dark.bg0,
      surfaceContainer: Gruvbox.dark.bg0S,
      surfaceContainerHigh: Gruvbox.dark.bg1,
      surfaceContainerHighest: Gruvbox.dark.bg2,
      onSurfaceVariant: Gruvbox.dark.fg2,
      outline: Gruvbox.dark.graySoft,
      outlineVariant: Gruvbox.dark.bg3,
      shadow: Gruvbox.dark.fg0,
      scrim: Gruvbox.dark.fg0,
      inverseSurface: Gruvbox.dark.fg0,
      onInverseSurface: Gruvbox.dark.bg,
      inversePrimary: Gruvbox.light.purpleHard,
      surfaceTint: Gruvbox.dark.purpleHard,
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
        fillColor: colors.surface,
        border: border,
        enabledBorder: border.copyWith(
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
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
        backgroundColor: colors.surfaceContainerHigh,
        indicatorColor: colors.primaryContainer,
        height: 72,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      switchTheme: SwitchThemeData(
        thumbIcon: WidgetStateProperty.resolveWith(
          (states) => Icon(
            states.contains(WidgetState.selected)
                ? Icons.check_rounded
                : Icons.close_rounded,
          ),
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primaryContainer
              : colors.outline,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.outline,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.inverseSurface,
        contentTextStyle: TextStyle(color: colors.onInverseSurface),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.tertiaryContainer;
            }
            return Colors.transparent;
          }),
          textStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
