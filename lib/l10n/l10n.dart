import 'package:flutter/widgets.dart';
import 'package:loc/l10n/app_localizations.dart';
import 'package:loc/l10n/app_localizations_en.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      AppLocalizationsEn();
}

Future<AppLocalizations> loadAppLocalizations(String? languageCode) {
  final locale = AppLocalizations.supportedLocales.firstWhere(
    (locale) => locale.languageCode == languageCode,
    orElse: () => const Locale('en'),
  );
  return AppLocalizations.delegate.load(locale);
}
