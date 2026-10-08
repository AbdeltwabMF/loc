import 'package:hive/hive.dart';
import 'package:loc/data/models/reminder.dart';

class AppRepository {
  AppRepository(this._reminders, this._preferences);

  final Box<dynamic> _reminders;
  final Box<dynamic> _preferences;

  List<Reminder> loadReminders() =>
      _reminders.values.whereType<Reminder>().toList(growable: false);

  Future<void> saveReminder(Reminder reminder) =>
      _reminders.put(reminder.id, reminder);

  Future<void> deleteReminder(String id) => _reminders.delete(id);

  String loadThemeMode() {
    final value = _preferences.get('themeMode', defaultValue: 'system');
    return value is String ? value.toLowerCase() : 'system';
  }

  String? loadLocaleCode() {
    final value = _preferences.get('localeCode');
    return value == 'en' || value == 'ar' ? value as String : null;
  }

  bool loadAlarmEnabled() {
    final value = _preferences.get('alarmEnabled', defaultValue: true);
    return value is bool ? value : true;
  }

  bool loadBackgroundTrackingEnabled() {
    final value = _preferences.get(
      'backgroundTrackingEnabled',
      defaultValue: false,
    );
    return value is bool ? value : false;
  }

  bool loadUseSystemFont() {
    final value = _preferences.get('useSystemFont');
    if (value is bool) return value;

    final legacyValue = _preferences.get('useGoogleSans');
    return legacyValue is bool ? !legacyValue : false;
  }

  bool loadTrackingSetupSeen() {
    final value = _preferences.get('trackingSetupSeen');
    return value is bool ? value : false;
  }

  Future<void> saveThemeMode(String value) =>
      _preferences.put('themeMode', value);

  Future<void> saveLocaleCode(String? value) => value == null
      ? _preferences.delete('localeCode')
      : _preferences.put('localeCode', value);

  Future<void> saveAlarmEnabled(bool value) =>
      _preferences.put('alarmEnabled', value);

  Future<void> saveBackgroundTrackingEnabled(bool value) =>
      _preferences.put('backgroundTrackingEnabled', value);

  Future<void> saveUseSystemFont(bool value) async {
    await _preferences.put('useSystemFont', value);
    await _preferences.delete('useGoogleSans');
  }

  Future<void> saveTrackingSetupSeen(bool value) =>
      _preferences.put('trackingSetupSeen', value);
}
