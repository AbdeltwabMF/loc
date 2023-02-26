import 'package:flutter/material.dart';

class GruvboxDarkPalette {
  GruvboxDarkPalette._();

  static const bg = Color(0xFF282828);
  static const bg0h = Color(0xFF1d2021);
  static const bg0s = Color(0xFF32302f);
  static const bg1 = Color(0xFF3c3836);
  static const bg2 = Color(0xFF504945);
  static const bg3 = Color(0xFF665c54);
  static const bg4 = Color(0xFF7c6f64);

  static const fg = Color(0xFFebdbb2);
  static const fg0 = Color(0xFFfbf1c7);
  static const fg1 = Color(0xFFebdbb2);
  static const fg2 = Color(0xFFd5c4a1);
  static const fg3 = Color(0xFFbdae93);
  static const fg4 = Color(0xFFa89984);

  static const darkRed = Color(0xFFcc241d);
  static const lightRed = Color(0xFFfb4934);
  static const darkGreen = Color(0xFF98971a);
  static const lightGreen = Color(0xFFb8bb26);
  static const darkYellow = Color(0xFFd79921);
  static const lightYellow = Color(0xFFfabd2f);
  static const darkBlue = Color(0xFF458588);
  static const lightBlue = Color(0xFF83a598);
  static const darkPurple = Color(0xFFb16268);
  static const lightPurple = Color(0xFFd3869b);
  static const darkAqua = Color(0xFF689d6a);
  static const lightAqua = Color(0xFF8ec07c);
  static const darkGrey = Color(0xFFa89984);
  static const lightGrey = Color(0xFFebdbb2);
  static const darkOrange = Color(0xFFd65d0e);
  static const lightOrange = Color(0xFFfe8019);
}

class GruvboxLightPalette {
  GruvboxLightPalette._();

  static const bg = Color(0xFFfbf1c7);
  static const bg0h = Color(0xFFf9f5d7);
  static const bg0s = Color(0xFFf2e5bc);
  static const bg1 = Color(0xFFebdbb2);
  static const bg2 = Color(0xFFd5c4a1);
  static const bg3 = Color(0xFFbdae93);
  static const bg4 = Color(0xFFa89984);

  static const fg = Color(0xFF3c3836);
  static const fg0 = Color(0xFF282828);
  static const fg1 = Color(0xFF3c3836);
  static const fg2 = Color(0xFF504945);
  static const fg3 = Color(0xFF665c54);
  static const fg4 = Color(0xFF7c6f64);

  static const darkRed = Color(0xFF9d0006);
  static const lightRed = Color(0xFFcc241d);
  static const darkGreen = Color(0xFF79740e);
  static const lightGreen = Color(0xFF98971a);
  static const darkYellow = Color(0xFFb57614);
  static const lightYellow = Color(0xFFd79921);
  static const darkBlue = Color(0xFF076678);
  static const lightBlue = Color(0xFF458588);
  static const darkPurple = Color(0xFF8f3f71);
  static const lightPurple = Color(0xFFb16286);
  static const darkAqua = Color(0xFF427b58);
  static const lightAqua = Color(0xFF689d6a);
  static const darkGrey = Color(0xFF7c6f64);
  static const lightGrey = Color(0xFF928374);
  static const darkOrange = Color(0xFFaf3a03);
  static const lightOrange = Color(0xFFd65d0e);
}

const ColorScheme lightColorScheme = ColorScheme(
  primary: GruvboxLightPalette.fg,
  onPrimary: GruvboxLightPalette.bg0h,
  primaryContainer: GruvboxLightPalette.darkPurple,
  onPrimaryContainer: GruvboxLightPalette.bg,
  secondary: GruvboxLightPalette.fg1,
  onSecondary: GruvboxLightPalette.bg1,
  secondaryContainer: GruvboxLightPalette.darkBlue,
  onSecondaryContainer: GruvboxLightPalette.bg0h,
  tertiary: GruvboxLightPalette.bg2,
  onTertiary: GruvboxLightPalette.fg4,
  background: GruvboxLightPalette.bg0h,
  onBackground: GruvboxLightPalette.fg2,
  error: GruvboxLightPalette.darkRed,
  onError: GruvboxLightPalette.bg0h,
  surface: GruvboxLightPalette.bg1,
  onSurface: GruvboxLightPalette.fg,
  outline: GruvboxLightPalette.darkOrange,
  brightness: Brightness.light,
);

const ColorScheme darkColorScheme = ColorScheme(
  primary: GruvboxDarkPalette.fg,
  onPrimary: GruvboxDarkPalette.bg0h,
  primaryContainer: GruvboxDarkPalette.darkBlue,
  onPrimaryContainer: GruvboxDarkPalette.bg,
  secondary: GruvboxDarkPalette.fg1,
  onSecondary: GruvboxDarkPalette.bg1,
  secondaryContainer: GruvboxDarkPalette.darkBlue,
  onSecondaryContainer: GruvboxDarkPalette.bg0h,
  tertiary: GruvboxDarkPalette.bg2,
  onTertiary: GruvboxDarkPalette.fg4,
  background: GruvboxDarkPalette.bg0h,
  onBackground: GruvboxDarkPalette.bg2,
  error: GruvboxDarkPalette.darkRed,
  onError: GruvboxDarkPalette.bg0h,
  surface: GruvboxDarkPalette.bg1,
  onSurface: GruvboxDarkPalette.fg,
  outline: GruvboxDarkPalette.lightOrange,
  brightness: Brightness.dark,
);
