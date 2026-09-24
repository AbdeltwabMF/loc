import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/app_repository.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/location_service.dart';
import 'package:loc/data/services/notification_service.dart';

void main() {
  group('AppController arrival lifecycle', () {
    test(
      'clears arrival beyond the exit buffer without stopping tracking',
      () async {
        final harness = await _Harness.create([_reminder()]);
        addTearDown(harness.dispose);

        harness.location.emit(_pointAtMeters(50));
        await _waitFor(() => harness.reminder.isArrived);

        await harness.emitAndWait(_pointAtMeters(120));
        expect(harness.reminder.isArrived, isTrue);

        harness.location.emit(_pointAtMeters(130));
        await _waitFor(() => !harness.reminder.isArrived);

        expect(harness.reminder.isAcknowledged, isFalse);
        expect(harness.controller.isTrackingLocation, isTrue);
        expect(harness.notifications.current, isNull);
      },
    );

    test(
      'dismisses one visit and alerts again after exit and re-entry',
      () async {
        final harness = await _Harness.create([_reminder()]);
        addTearDown(harness.dispose);

        harness.location.emit(_pointAtMeters(50));
        await _waitFor(() => harness.notifications.shown.length == 1);
        await harness.controller.dismissArrival();

        expect(harness.reminder.isArrived, isTrue);
        expect(harness.reminder.isAcknowledged, isTrue);
        expect(harness.controller.isTrackingLocation, isTrue);

        harness.location.emit(_pointAtMeters(130));
        await _waitFor(() => !harness.reminder.isArrived);
        harness.location.emit(_pointAtMeters(50));
        await _waitFor(() => harness.notifications.shown.length == 2);

        expect(harness.reminder.isArrived, isTrue);
        expect(harness.reminder.isAcknowledged, isFalse);
      },
    );

    test('editing preserves the current acknowledged visit', () async {
      final harness = await _Harness.create([_reminder()]);
      addTearDown(harness.dispose);

      harness.location.emit(_pointAtMeters(50));
      await _waitFor(() => harness.notifications.shown.length == 1);
      await harness.controller.dismissArrival();

      await harness.controller.saveReminder(
        harness.reminder.copy(
          title: 'Updated station',
          isArrived: false,
          isAcknowledged: false,
        ),
      );

      expect(harness.reminder.isArrived, isTrue);
      expect(harness.reminder.isAcknowledged, isTrue);
      expect(harness.notifications.shown, hasLength(1));
    });

    test(
      'replaces the shared notification when the arrived reminder changes',
      () async {
        final first = _reminder(title: 'First', isAlarm: true);
        final second = _reminder(
          id: 'second',
          title: 'Second',
          latitude: _latitudeAtMeters(200),
        );
        final harness = await _Harness.create([
          first,
          second,
        ], initialMeters: -200);
        addTearDown(harness.dispose);

        harness.location.emit(_pointAtMeters(0));
        await _waitFor(() => harness.notifications.shown.length == 1);
        expect(harness.notifications.shown.last.body, 'First');
        expect(harness.notifications.shown.last.isAlarm, isTrue);

        harness.location.emit(_pointAtMeters(200));
        await _waitFor(() => harness.notifications.shown.length == 2);

        expect(harness.notifications.shown.last.body, 'Second');
        expect(harness.notifications.shown.last.isAlarm, isFalse);
        expect(harness.notifications.shown.last.isVibration, isFalse);
        expect(harness.controller.isTrackingLocation, isTrue);
      },
    );

    test('clears a stale persisted arrival before startup alerts', () async {
      final harness = await _Harness.create([_reminder(isArrived: true)]);
      addTearDown(harness.dispose);

      await _waitFor(() => !harness.reminder.isArrived);

      expect(harness.reminder.isArrived, isFalse);
      expect(harness.notifications.shown, isEmpty);
      expect(harness.controller.isTrackingLocation, isTrue);
    });
  });

  group('AppController attention actions', () {
    test(
      'opens app settings when notification permission stays denied',
      () async {
        final location = _FakeLocationService(_pointAtMeters(200));
        final notifications = _FakeNotificationService(
          permissionGranted: false,
          requestResult: false,
        );
        final controller = AppController(
          repository: _FakeRepository([_reminder()]),
          locationService: location,
          notificationService: notifications,
        );
        addTearDown(() {
          controller.dispose();
          unawaited(location.close());
        });

        await controller.initialize();
        expect(
          controller.attentionAction,
          AttentionAction.requestNotifications,
        );

        await controller.resolveAttention();
        expect(location.appSettingsOpens, 1);
      },
    );

    test('opens device settings when location services are disabled', () async {
      final location = _FakeLocationService(
        _pointAtMeters(200),
        status: LocationAccessStatus.serviceDisabled,
      );
      final controller = AppController(
        repository: _FakeRepository([_reminder()]),
        locationService: location,
        notificationService: _FakeNotificationService(),
      );
      addTearDown(() {
        controller.dispose();
        unawaited(location.close());
      });

      await controller.initialize();
      expect(controller.attentionAction, AttentionAction.enableLocation);

      await controller.resolveAttention();
      expect(location.locationSettingsOpens, 1);
    });

    test('opens app settings when background location is required', () async {
      final location = _FakeLocationService(
        _pointAtMeters(200),
        status: LocationAccessStatus.settingsRequired,
      );
      final controller = AppController(
        repository: _FakeRepository([_reminder()]),
        locationService: location,
        notificationService: _FakeNotificationService(),
      );
      addTearDown(() {
        controller.dispose();
        unawaited(location.close());
      });

      await controller.initialize();
      expect(controller.attentionAction, AttentionAction.openAppSettings);

      await controller.resolveAttention();
      expect(location.appSettingsOpens, 1);
    });
  });
}

Reminder _reminder({
  String id = 'first',
  String title = 'Station',
  double latitude = 0,
  bool isArrived = false,
  bool isAlarm = false,
}) => Reminder(
  id: id,
  title: title,
  place: Place(position: Point(latitude: latitude, longitude: 0), radius: 100),
  initialDistance: 0,
  isTracking: true,
  isArrived: isArrived,
  isAlarm: isAlarm,
);

Point _pointAtMeters(double meters) =>
    Point(latitude: _latitudeAtMeters(meters), longitude: 0);

double _latitudeAtMeters(double meters) => meters / 111320;

Future<void> _waitFor(bool Function() condition) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail('Timed out waiting for controller state');
}

class _Harness {
  _Harness({
    required this.controller,
    required this.location,
    required this.notifications,
  });

  final AppController controller;
  final _FakeLocationService location;
  final _FakeNotificationService notifications;

  Reminder get reminder => controller.reminders.first;

  Future<void> emitAndWait(Point point) async {
    final updated = Completer<void>();
    void listener() {
      if (controller.currentPosition == point && !updated.isCompleted) {
        updated.complete();
      }
    }

    controller.addListener(listener);
    location.emit(point);
    await updated.future;
    controller.removeListener(listener);
  }

  static Future<_Harness> create(
    List<Reminder> reminders, {
    double initialMeters = 200,
  }) async {
    final repository = _FakeRepository(reminders);
    final location = _FakeLocationService(_pointAtMeters(initialMeters));
    final notifications = _FakeNotificationService();
    final controller = AppController(
      repository: repository,
      locationService: location,
      notificationService: notifications,
    );
    await controller.initialize();
    await _waitFor(() => controller.currentPosition != null);
    return _Harness(
      controller: controller,
      location: location,
      notifications: notifications,
    );
  }

  Future<void> dispose() async {
    controller.dispose();
    await location.close();
  }
}

class _FakeRepository implements AppRepository {
  _FakeRepository(Iterable<Reminder> reminders)
    : _reminders = {for (final reminder in reminders) reminder.id: reminder};

  final Map<String, Reminder> _reminders;
  final List<Place> _savedPlaces = [];
  String _themeMode = 'system';
  bool _alarmEnabled = true;

  @override
  Future<void> deleteSavedPlace(Place place) async {
    _savedPlaces.remove(place);
  }

  @override
  Future<void> deleteReminder(String id) async {
    _reminders.remove(id);
  }

  @override
  List<Place> loadSavedPlaces() => List.of(_savedPlaces);

  @override
  bool loadAlarmEnabled() => _alarmEnabled;

  @override
  List<Reminder> loadReminders() => List.of(_reminders.values);

  @override
  String loadThemeMode() => _themeMode;

  @override
  Future<void> migrateLegacyData() async {}

  @override
  Future<void> saveAlarmEnabled(bool value) async {
    _alarmEnabled = value;
  }

  @override
  Future<void> saveSavedPlace(Place place) async {
    _savedPlaces.add(place);
  }

  @override
  Future<void> saveReminder(Reminder reminder) async {
    _reminders[reminder.id] = reminder;
  }

  @override
  Future<void> saveThemeMode(String value) async {
    _themeMode = value;
  }
}

class _FakeLocationService implements LocationService {
  _FakeLocationService(
    this.currentPoint, {
    this.status = LocationAccessStatus.ready,
  });

  final StreamController<Point> _updates = StreamController<Point>();
  Point currentPoint;
  LocationAccessStatus status;
  int appSettingsOpens = 0;
  int locationSettingsOpens = 0;

  @override
  Future<LocationAccessStatus> accessStatus({bool background = true}) async =>
      status;

  @override
  Future<Point> current() async => currentPoint;

  @override
  Future<void> ensurePermission({bool background = false}) async {}

  @override
  Future<bool> hasPermission() async => true;

  @override
  Stream<Point> get updates => _updates.stream;

  @override
  Future<String> unavailableReason() async => '';

  @override
  Future<bool> openAppSettings() async {
    appSettingsOpens++;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    locationSettingsOpens++;
    return true;
  }

  void emit(Point point) {
    currentPoint = point;
    _updates.add(point);
  }

  Future<void> close() => _updates.close();
}

class _FakeNotificationService implements NotificationService {
  _FakeNotificationService({
    this.permissionGranted = true,
    this.requestResult = true,
  });

  final List<_ArrivalNotification> shown = [];
  _ArrivalNotification? current;
  bool permissionGranted;
  bool requestResult;

  @override
  Future<void> dismissArrival() async {
    current = null;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isPermissionGranted() async => permissionGranted;

  @override
  Future<bool> requestPermission() async {
    permissionGranted = requestResult;
    return requestResult;
  }

  @override
  Future<void> showArrival({
    required String title,
    required String body,
    required bool isAlarm,
    required bool isVibration,
  }) async {
    final notification = _ArrivalNotification(
      body: body,
      isAlarm: isAlarm,
      isVibration: isVibration,
    );
    shown.add(notification);
    current = notification;
  }
}

class _ArrivalNotification {
  const _ArrivalNotification({
    required this.body,
    required this.isAlarm,
    required this.isVibration,
  });

  final String body;
  final bool isAlarm;
  final bool isVibration;
}
