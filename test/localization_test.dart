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
}
