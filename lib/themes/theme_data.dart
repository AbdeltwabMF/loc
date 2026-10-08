import 'package:flutter/material.dart';
import 'package:loc/themes/tokens.dart';

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
      primary: Gruvbox.light.blueHard,
      onPrimary: Gruvbox.light.bg,
      primaryContainer: Gruvbox.light.blueSoft,
      onPrimaryContainer: Gruvbox.light.bg,
      secondary: Gruvbox.light.greenHard,
      onSecondary: Gruvbox.light.bg,
      secondaryContainer: Gruvbox.light.greenSoft,
      onSecondaryContainer: Gruvbox.light.bg,
      tertiary: Gruvbox.light.orangeHard,
      onTertiary: Gruvbox.light.bg,
      tertiaryContainer: Gruvbox.light.orangeSoft,
      onTertiaryContainer: Gruvbox.light.bg,
      error: Gruvbox.light.redHard,
      onError: Gruvbox.light.bg,
      errorContainer: Gruvbox.light.redSoft,
      onErrorContainer: Gruvbox.light.bg,
      surface: Gruvbox.light.bg,
      onSurface: Gruvbox.light.fg,
      surfaceContainerLowest: Gruvbox.light.bg0H,
      surfaceContainerLow: Gruvbox.light.bg0,
      surfaceContainer: Gruvbox.light.bg0S,
      surfaceContainerHigh: Gruvbox.light.bg1,
      surfaceContainerHighest: Gruvbox.light.bg2,
      onSurfaceVariant: Gruvbox.light.fg1,
      outline: Gruvbox.light.grayHard,
      outlineVariant: Gruvbox.light.graySoft,
      shadow: Gruvbox.light.fg,
      scrim: Gruvbox.light.fg,
      inverseSurface: Gruvbox.light.fg,
      onInverseSurface: Gruvbox.light.bg,
      inversePrimary: Gruvbox.dark.blueSoft,
      surfaceTint: Gruvbox.light.blueSoft,
    ),
  );

  static final themeDark = _build(
    ColorScheme(
      brightness: Brightness.dark,
      primary: Gruvbox.dark.blueSoft,
      onPrimary: Gruvbox.dark.bg,
      primaryContainer: Gruvbox.dark.blueHard,
      onPrimaryContainer: Gruvbox.dark.bg,
      secondary: Gruvbox.dark.greenSoft,
      onSecondary: Gruvbox.dark.bg,
      secondaryContainer: Gruvbox.dark.greenHard,
      onSecondaryContainer: Gruvbox.dark.bg,
      tertiary: Gruvbox.dark.orangeSoft,
      onTertiary: Gruvbox.dark.bg,
      tertiaryContainer: Gruvbox.dark.orangeHard,
      onTertiaryContainer: Gruvbox.dark.bg,
      error: Gruvbox.dark.redSoft,
      onError: Gruvbox.dark.bg,
      errorContainer: Gruvbox.dark.redHard,
      onErrorContainer: Gruvbox.dark.bg,
      surface: Gruvbox.dark.bg,
      onSurface: Gruvbox.dark.fg,
      surfaceContainerLowest: Gruvbox.dark.bg0H,
      surfaceContainerLow: Gruvbox.dark.bg0,
      surfaceContainer: Gruvbox.dark.bg0S,
      surfaceContainerHigh: Gruvbox.dark.bg1,
      surfaceContainerHighest: Gruvbox.dark.bg2,
      onSurfaceVariant: Gruvbox.dark.fg1,
      outline: Gruvbox.dark.grayHard,
      outlineVariant: Gruvbox.dark.graySoft,
      shadow: Gruvbox.dark.fg,
      scrim: Gruvbox.dark.fg,
      inverseSurface: Gruvbox.dark.fg,
      onInverseSurface: Gruvbox.dark.bg,
      inversePrimary: Gruvbox.light.blueHard,
      surfaceTint: Gruvbox.dark.blueHard,
    ),
  );

  static final _googleSansThemeLight = _build(
    themeLight.colorScheme,
    fontFamily: AppTypography.googleSans,
  );

  static final _googleSansThemeDark = _build(
    themeDark.colorScheme,
    fontFamily: AppTypography.googleSans,
  );

  static final _balooBhaijaan2ThemeLight = _build(
    themeLight.colorScheme,
    fontFamily: AppTypography.balooBhaijaan2,
  );

  static final _balooBhaijaan2ThemeDark = _build(
    themeDark.colorScheme,
    fontFamily: AppTypography.balooBhaijaan2,
  );

  static ThemeData light({
    required bool useSystemFont,
    String languageCode = 'en',
  }) {
    if (useSystemFont) return themeLight;
    return switch (AppTypography.bundledFamilyFor(languageCode)) {
      AppTypography.googleSans => _googleSansThemeLight,
      AppTypography.balooBhaijaan2 => _balooBhaijaan2ThemeLight,
      _ => themeLight,
    };
  }

  static ThemeData dark({
    required bool useSystemFont,
    String languageCode = 'en',
  }) {
    if (useSystemFont) return themeDark;
    return switch (AppTypography.bundledFamilyFor(languageCode)) {
      AppTypography.googleSans => _googleSansThemeDark,
      AppTypography.balooBhaijaan2 => _balooBhaijaan2ThemeDark,
      _ => themeDark,
    };
  }

  static ThemeData _build(ColorScheme colors, {String? fontFamily}) {
    final border = OutlineInputBorder(
      borderRadius: AppRadius.textFieldRadius,
      borderSide: BorderSide.none,
    );

    final controlShape = RoundedRectangleBorder(
      borderRadius: AppRadius.buttonRadius,
    );

    return ThemeData(
      colorScheme: colors,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colors.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontFamily: fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: colors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogRadius),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: AppSpacing.group,
        ),
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontFamily: fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w400,
          height: 32 / 24,
        ),
        contentTextStyle: TextStyle(
          color: colors.onSurfaceVariant,
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.menuRadius,
          side: BorderSide(color: colors.outlineVariant),
        ),
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
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: TextStyle(
          color: colors.onSurfaceVariant,
          fontFamily: fontFamily,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          color: colors.onSurfaceVariant,
          fontFamily: fontFamily,
          fontSize: 16,
        ),
        helperStyle: TextStyle(
          color: colors.onSurfaceVariant,
          fontFamily: fontFamily,
          fontSize: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppControlHeights.control),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          shape: controlShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppControlHeights.control),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          side: BorderSide(color: colors.outlineVariant),
          foregroundColor: colors.onSurface,
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, AppControlHeights.control),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: colors.primaryContainer.withAlpha(79),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.chipRadius),
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.outlineVariant,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.fabRadius),
      ),
      switchTheme: SwitchThemeData(
        thumbIcon: WidgetStateProperty.resolveWith(
          (states) => Icon(
            states.contains(WidgetState.selected)
                ? Icons.check_rounded
                : Icons.close_rounded,
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.onInverseSurface,
          ),
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.onPrimary
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
        contentTextStyle: TextStyle(
          color: colors.onInverseSurface,
          fontFamily: fontFamily,
        ),
      ),
      sliderTheme: SliderThemeData(
        tickMarkShape: SliderTickMarkShape.noTickMark,
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w400,
          height: 32 / 24,
          color: colors.onSurface,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w400,
          height: 28 / 22,
          color: colors.onSurface,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: colors.onSurface,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: colors.onSurface,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.45,
          color: colors.onSurface,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 16 / 12,
          color: colors.onSurface,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(0, AppControlHeights.control),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.primaryContainer;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.onPrimaryContainer;
            }
            return colors.onSurfaceVariant;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: colors.outlineVariant),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          ),
          textStyle: WidgetStatePropertyAll(
            TextStyle(
              fontFamily: fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
