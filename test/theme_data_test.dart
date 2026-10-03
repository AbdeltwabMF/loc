import 'package:flutter_test/flutter_test.dart';
import 'package:loc/themes/theme_data.dart';
import 'package:loc/themes/tokens.dart';

void main() {
  test('Google Sans theme applies the family to text and components', () {
    final theme = AppTheme.light(useGoogleSans: true);

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
    final theme = AppTheme.light(useGoogleSans: false);

    expect(
      theme.textTheme.bodyMedium?.fontFamily,
      isNot(AppTypography.googleSans),
    );
    expect(
      theme.appBarTheme.titleTextStyle?.fontFamily,
      isNot(AppTypography.googleSans),
    );
  });
}
