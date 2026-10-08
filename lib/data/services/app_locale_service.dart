import 'package:flutter/services.dart';

class AppLocaleService {
  static const _channel = MethodChannel('xyz.abdeltwab.loc/locale');

  static Future<void> setApplicationLocale(String? languageCode) async {
    try {
      await _channel.invokeMethod<void>('setApplicationLocale', languageCode);
    } on MissingPluginException {
      // Non-Android platforms and widget tests use Flutter's locale directly.
    }
  }

  static Future<({bool supported, String? languageCode})>
  getApplicationLocale() async {
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'getApplicationLocale',
      );
      return (
        supported: result?['supported'] == true,
        languageCode: result?['languageCode'] as String?,
      );
    } on MissingPluginException {
      return (supported: false, languageCode: null);
    }
  }
}
