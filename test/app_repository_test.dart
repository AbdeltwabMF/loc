import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:loc/data/app_repository.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';

void main() {
  late Directory directory;
  late Box<dynamic> reminders;
  late Box<dynamic> preferences;
  late AppRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('loc_repository_test_');
    Hive
      ..init(directory.path)
      ..registerAdapter(ReminderAdapter())
      ..registerAdapter(PlaceAdapter())
      ..registerAdapter(PointAdapter());
    reminders = await Hive.openBox<dynamic>('reminders');
    preferences = await Hive.openBox<dynamic>('preferences');
    repository = AppRepository(reminders, preferences);
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
    Hive.resetAdapters();
  });

  test('migration canonicalizes reminder keys once', () async {
    final reminder = _reminder('station');
    final duplicate = _reminder('station', title: 'Latest station');
    await reminders.putAll({0: reminder, 'stale-alias': duplicate, 'len': 2});

    await repository.migrateLegacyData();

    expect(reminders.keys, ['station']);
    expect(repository.loadReminders().single.title, 'Latest station');
    expect(preferences.get('dataMigrationVersion'), 1);

    await reminders.put('legacy-after-migration', _reminder('other'));
    await repository.migrateLegacyData();
    expect(reminders.containsKey('legacy-after-migration'), isTrue);
  });

  test('saving and deleting a reminder remove all legacy aliases', () async {
    final reminder = _reminder('station');
    await reminders.putAll({0: reminder, 'alias': reminder});

    await repository.saveReminder(reminder.copy(title: 'Updated'));

    expect(reminders.keys, ['station']);
    expect(repository.loadReminders().single.title, 'Updated');

    await reminders.put(1, reminder);
    await repository.deleteReminder('station');
    expect(repository.loadReminders(), isEmpty);
  });

  test('persists pinned reminders', () async {
    await repository.saveReminder(_reminder('station').copy(isPinned: true));
    await reminders.close();
    reminders = await Hive.openBox<dynamic>('reminders');
    repository = AppRepository(reminders, preferences);

    expect(repository.loadReminders().single.isPinned, isTrue);
  });

  test('current adapter reads records and discards retired fields', () async {
    await Hive.close();
    Hive
      ..resetAdapters()
      ..registerAdapter(_LegacyReminderAdapter())
      ..registerAdapter(PlaceAdapter())
      ..registerAdapter(PointAdapter());
    final legacyBox = await Hive.openBox<dynamic>('legacy-reminders');
    await legacyBox.put('station', _LegacyReminder());
    await Hive.close();

    Hive
      ..resetAdapters()
      ..registerAdapter(ReminderAdapter())
      ..registerAdapter(PlaceAdapter())
      ..registerAdapter(PointAdapter());
    final migratedBox = await Hive.openBox<dynamic>('legacy-reminders');

    final reminder = migratedBox.get('station') as Reminder;
    expect(reminder.title, 'Legacy station');
    expect(reminder.isTracking, isTrue);
    expect(reminder.isAlarm, isFalse);
    expect(reminder.isPinned, isFalse);
  });
}

Reminder _reminder(String id, {String title = 'Station'}) => Reminder(
  id: id,
  title: title,
  place: Place(position: Point(latitude: 30, longitude: 31)),
  isTracking: true,
  isArrived: false,
);

class _LegacyReminder {}

class _LegacyReminderAdapter extends TypeAdapter<_LegacyReminder> {
  @override
  int get typeId => 1;

  @override
  _LegacyReminder read(BinaryReader reader) => throw UnimplementedError();

  @override
  void write(BinaryWriter writer, _LegacyReminder object) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write('station')
      ..writeByte(1)
      ..write('Legacy station')
      ..writeByte(2)
      ..write(Place(position: Point(latitude: 30, longitude: 31)))
      ..writeByte(3)
      ..write(1200.0)
      ..writeByte(4)
      ..write(true)
      ..writeByte(5)
      ..write(false)
      ..writeByte(6)
      ..write('Retired note')
      ..writeByte(7)
      ..write(false)
      ..writeByte(8)
      ..write(false)
      ..writeByte(9)
      ..write(false);
  }
}
