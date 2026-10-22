import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loc/l10n/app_localizations.dart';
import 'package:loc/l10n/l10n.dart';

void main() {
  testWidgets('Arabic locale supplies translated RTL content', (tester) async {
    late TextDirection direction;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) {
            direction = Directionality.of(context);
            return Text(context.l10n.settingsTitle);
          },
        ),
      ),
    );

    expect(direction, TextDirection.rtl);
    expect(find.text('الإعدادات'), findsOneWidget);
  });

  testWidgets('Brazilian Portuguese locale supplies translated content', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(builder: (context) => Text(context.l10n.settingsTitle)),
      ),
    );

    expect(find.text('Configurações'), findsOneWidget);
  });

  test('unsupported device locale falls back to English', () {
    final locale = resolveAppLocale(const [
      Locale('de'),
    ], AppLocalizations.supportedLocales);

    expect(locale, const Locale('en'));
  });
}
