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

  bool loadUseGoogleSans() {
    final value = _preferences.get('useGoogleSans', defaultValue: true);
    return value is bool ? value : true;
  }

  Future<void> saveThemeMode(String value) =>
      _preferences.put('themeMode', value);

  Future<void> saveAlarmEnabled(bool value) =>
      _preferences.put('alarmEnabled', value);

  Future<void> saveBackgroundTrackingEnabled(bool value) =>
      _preferences.put('backgroundTrackingEnabled', value);

  Future<void> saveUseGoogleSans(bool value) =>
      _preferences.put('useGoogleSans', value);
}
