import 'package:flutter/material.dart';

/// App-level typography tokens used by the shared themes.
abstract final class AppTypography {
  static const String googleSans = 'GoogleSans';
}

/// App-level spacing tokens based on a 4dp grid.
///
/// Avoid arbitrary per-screen values: prefer these constants so cards,
/// dialogs, menus, and buttons stay visually consistent.
abstract final class AppSpacing {
  /// Outer page gutter.
  static const double page = 16.0;

  /// Card inner padding.
  static const double card = 16.0;

  /// Material dialog content padding.
  static const double dialog = 24.0;

  /// Gap between a title and its subtitle (4-8dp).
  static const double titleGap = 4.0;

  /// Gap between logical groups.
  static const double group = 24.0;

  /// Tighter gap inside compact rows.
  static const double compact = 8.0;

  /// Smallest rhythm step.
  static const double xs = 2.0;
  static const double sm = 4.0;
}

/// Semantic Material 3 component shape tokens.
///
/// Component names avoid applying one generic radius to controls with
/// different Material shape roles.
abstract final class AppRadius {
  static const double textField = 4.0;
  static const double menu = 4.0;
  static const double chip = 8.0;
  static const double card = 12.0;
  static const double button = 20.0;
  static const double fab = 16.0;
  static const double dialog = 28.0;

  static BorderRadius get textFieldRadius => BorderRadius.circular(textField);
  static BorderRadius get menuRadius => BorderRadius.circular(menu);
  static BorderRadius get chipRadius => BorderRadius.circular(chip);
  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get buttonRadius => BorderRadius.circular(button);
  static BorderRadius get fabRadius => BorderRadius.circular(fab);
  static BorderRadius get dialogRadius => BorderRadius.circular(dialog);
}

/// Minimum touch-target and component heights.
abstract final class AppControlHeights {
  /// Minimum interactive height (48dp).
  static const double control = 48.0;
}
