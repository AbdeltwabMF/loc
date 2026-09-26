import 'package:hive/hive.dart';
import 'package:loc/data/models/reminder.dart';

class AppRepository {
  AppRepository(this._reminders, this._preferences);

  static const _migrationVersion = 1;
  static const _migrationVersionKey = 'dataMigrationVersion';

  final Box<dynamic> _reminders;
  final Box<dynamic> _preferences;

  Future<void> migrateLegacyData() async {
    final currentVersion = _preferences.get(
      _migrationVersionKey,
      defaultValue: 0,
    );
    if (currentVersion is int && currentVersion >= _migrationVersion) return;

    final reminders = <String, Reminder>{
      for (final reminder in loadReminders()) reminder.id: reminder,
    };
    // Write canonical records before deleting aliases so an interrupted
    // migration always leaves a recoverable copy.
    await _reminders.putAll(reminders);
    await _reminders.deleteAll(
      _reminders.keys.where((key) => !reminders.containsKey(key)).toList(),
    );
    await _preferences.put(_migrationVersionKey, _migrationVersion);
  }

  List<Reminder> loadReminders() =>
      _reminders.values.whereType<Reminder>().toList(growable: false);

  Future<void> saveReminder(Reminder reminder) async {
    final legacyKeys = _reminders.keys.where(
      (key) =>
          key != reminder.id &&
          _reminders.get(key) is Reminder &&
          (_reminders.get(key) as Reminder).id == reminder.id,
    );
    await _reminders.deleteAll(legacyKeys);
    await _reminders.put(reminder.id, reminder);
  }

  Future<void> deleteReminder(String id) async {
    final legacyKeys = _reminders.keys.where(
      (key) =>
          _reminders.get(key) is Reminder &&
          (_reminders.get(key) as Reminder).id == id,
    );
    await _reminders.deleteAll(legacyKeys);
  }

  String loadThemeMode() {
    final value = _preferences.get(
      'themeMode',
      defaultValue: _preferences.get('pre-themeMode', defaultValue: 'System'),
    );
    return value is String ? value.toLowerCase() : 'system';
  }

  bool loadAlarmEnabled() {
    final value = _preferences.get(
      'alarmEnabled',
      defaultValue: _preferences.get('pre-notify', defaultValue: true),
    );
    return value is bool ? value : true;
  }

  Future<void> saveThemeMode(String value) =>
      _preferences.put('themeMode', value);

  Future<void> saveAlarmEnabled(bool value) =>
      _preferences.put('alarmEnabled', value);
}
