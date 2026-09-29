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

  test('saves and deletes a reminder by id', () async {
    final reminder = _reminder('station');

    await repository.saveReminder(reminder.copy(title: 'Updated'));

    expect(reminders.keys, ['station']);
    expect(repository.loadReminders().single.title, 'Updated');

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

  test('persists optional background tracking preference', () async {
    expect(repository.loadBackgroundTrackingEnabled(), isFalse);

    await repository.saveBackgroundTrackingEnabled(true);

    expect(repository.loadBackgroundTrackingEnabled(), isTrue);
  });
}

Reminder _reminder(String id, {String title = 'Station'}) => Reminder(
  id: id,
  title: title,
  place: Place(position: Point(latitude: 30, longitude: 31)),
  isTracking: true,
  isArrived: false,
);
