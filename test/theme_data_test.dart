import 'package:flutter_test/flutter_test.dart';
import 'package:loc/themes/theme_data.dart';
import 'package:loc/themes/tokens.dart';

void main() {
  test('Google Sans theme applies the family to text and components', () {
    final theme = AppTheme.light(useSystemFont: false);

    expect(theme.textTheme.bodyMedium?.fontFamily, AppTypography.googleSans);
    expect(
      theme.appBarTheme.titleTextStyle?.fontFamily,
      AppTypography.googleSans,
    );
    expect(
      theme.dialogTheme.contentTextStyle?.fontFamily,
      AppTypography.googleSans,
    );
    expect(
      theme.filledButtonTheme.style?.textStyle?.resolve({})?.fontFamily,
      AppTypography.googleSans,
    );
  });

  test('system theme does not apply Google Sans', () {
    final theme = AppTheme.light(useSystemFont: true);

    expect(
      theme.textTheme.bodyMedium?.fontFamily,
      isNot(AppTypography.googleSans),
    );
    expect(
      theme.appBarTheme.titleTextStyle?.fontFamily,
      isNot(AppTypography.googleSans),
    );
  });

  test('Arabic custom theme uses Baloo Bhaijaan 2', () {
    final theme = AppTheme.light(useSystemFont: false, languageCode: 'ar');

    expect(
      theme.textTheme.bodyMedium?.fontFamily,
      AppTypography.balooBhaijaan2,
    );
    expect(
      theme.appBarTheme.titleTextStyle?.fontFamily,
      AppTypography.balooBhaijaan2,
    );
  });

  test('unknown languages fall back to the system font', () {
    final theme = AppTheme.light(useSystemFont: false, languageCode: 'fr');

    expect(
      theme.textTheme.bodyMedium?.fontFamily,
      isNot(anyOf(AppTypography.googleSans, AppTypography.balooBhaijaan2)),
    );
  });
}
