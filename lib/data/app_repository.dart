import 'package:hive/hive.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/reminder.dart';

class AppRepository {
  AppRepository(this._reminders, this._savedPlaces, this._preferences);

  final Box<dynamic> _reminders;
  final Box<dynamic> _savedPlaces;
  final Box<dynamic> _preferences;

  Future<void> migrateLegacyData() async {
    final reminders = loadReminders();
    final savedPlaces = <Place>[];
    for (final place in loadSavedPlaces()) {
      if (!savedPlaces.any((item) => item.isSameLocation(place))) {
        savedPlaces.add(place);
      }
    }
    await _reminders.putAll({for (final item in reminders) item.id: item});
    await _savedPlaces.clear();
    await _savedPlaces.putAll({
      for (final item in savedPlaces) _placeKey(item): item,
    });
    await _reminders.deleteAll(
      _reminders.keys.where((key) => key is! String || key == 'len'),
    );
  }

  List<Reminder> loadReminders() =>
      _reminders.values.whereType<Reminder>().toList(growable: false);

  List<Place> loadSavedPlaces() =>
      _savedPlaces.values.whereType<Place>().toList(growable: false);

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

  Future<void> saveSavedPlace(Place place) =>
      _savedPlaces.put(_placeKey(place), place);

  Future<void> deleteSavedPlace(Place place) async {
    final keys = _savedPlaces.keys.where(
      (key) => _savedPlaces.get(key) is Place && _savedPlaces.get(key) == place,
    );
    await _savedPlaces.deleteAll(keys);
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

  String _placeKey(Place place) =>
      '${place.position.latitude},${place.position.longitude}';
}
