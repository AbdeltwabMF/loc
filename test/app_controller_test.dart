import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:loc/app/app_controller.dart';
import 'package:loc/data/app_repository.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/background_tracking_service.dart';
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

        await harness.emitAndWait(_pointAtMeters(105));
        expect(harness.reminder.isArrived, isTrue);

        harness.location.emit(_pointAtMeters(115));
        await _waitFor(() => !harness.reminder.isArrived);

        expect(harness.reminder.isAcknowledged, isFalse);
        expect(harness.controller.isTrackingLocation, isTrue);
        expect(harness.notifications.current, isNull);
      },
    );

    test(
      'dismisses one visit and alerts again after exit and re-entry',
      () async {
        final harness = await _Harness.create([
          _reminder(),
        ], initialMeters: -200);
        addTearDown(harness.dispose);

        harness.location.emit(_pointAtMeters(200));
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

    test(
      'alerts again when an arrived reminder is paused and resumed',
      () async {
        final harness = await _Harness.create([
          _reminder(isAlarm: true),
        ], initialMeters: 50);
        addTearDown(harness.dispose);
        await _waitFor(() => harness.notifications.shown.length == 1);

        await harness.controller.setReminderTracking(harness.reminder, false);
        await harness.controller.setReminderTracking(harness.reminder, true);

        expect(harness.notifications.shown, hasLength(2));
        expect(harness.notifications.shown.last.isAlarm, isTrue);
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
      'retries a failed position update without restarting tracking',
      () async {
        final harness = await _Harness.create([_reminder()]);
        addTearDown(harness.dispose);
        harness.repository.saveFailuresRemaining = 1;

        harness.location.emit(_pointAtMeters(50));
        await _waitFor(
          () => harness.controller.attentionAction == AttentionAction.retry,
        );

        expect(harness.controller.isTrackingLocation, isTrue);
        expect(harness.reminder.isArrived, isFalse);

        await harness.controller.resolveAttention();

        expect(harness.reminder.isArrived, isTrue);
        expect(harness.controller.attentionAction, isNull);
        expect(harness.controller.locationError, isNull);
      },
    );

    test('retries a failed arrival notification', () async {
      final harness = await _Harness.create([_reminder()]);
      addTearDown(harness.dispose);
      harness.notifications.showFailuresRemaining = 1;

      harness.location.emit(_pointAtMeters(50));
      await _waitFor(
        () => harness.controller.attentionAction == AttentionAction.retry,
      );

      await harness.controller.resolveAttention();

      expect(harness.notifications.shown, hasLength(1));
      expect(harness.controller.attentionAction, isNull);
    });

    test('turning off system notifications keeps the in-app arrival', () async {
      final harness = await _Harness.create([_reminder()]);
      addTearDown(harness.dispose);
      harness.location.emit(_pointAtMeters(50));
      await _waitFor(() => harness.controller.hasArrivalAlert);

      await harness.controller.setAlarmEnabled(false);

      expect(harness.controller.hasArrivalAlert, isTrue);
      expect(harness.reminder.isAcknowledged, isFalse);
      expect(harness.notifications.current, isNull);
    });

    test('notifies after tracking stops for the final reminder', () async {
      final harness = await _Harness.create([_reminder()]);
      addTearDown(harness.dispose);
      final observedTrackingStates = <bool>[];
      harness.controller.addListener(
        () => observedTrackingStates.add(harness.controller.isTrackingLocation),
      );

      await harness.controller.setReminderTracking(harness.reminder, false);

      expect(observedTrackingStates, isNotEmpty);
      expect(observedTrackingStates, everyElement(isFalse));
    });

    test('tracks while notification permission stays denied', () async {
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
      expect(controller.attentionAction, isNull);
      expect(controller.isTrackingLocation, isTrue);
      expect(controller.notificationsAllowed, isFalse);

      expect(await controller.setAlarmEnabled(true), isFalse);
      expect(controller.systemNotificationsEnabled, isFalse);
    });

    test(
      'tracks with in-app alerts when system notifications are off',
      () async {
        final location = _FakeLocationService(_pointAtMeters(200));
        final notifications = _FakeNotificationService(
          permissionGranted: false,
        );
        final repository = _FakeRepository([_reminder()])
          .._alarmEnabled = false;
        final controller = AppController(
          repository: repository,
          locationService: location,
          notificationService: notifications,
        );
        addTearDown(() {
          controller.dispose();
          unawaited(location.close());
        });

        await controller.initialize();
        location.emit(_pointAtMeters(50));
        await _waitFor(() => controller.hasArrivalAlert);

        expect(controller.isTrackingLocation, isTrue);
        expect(controller.attentionAction, isNull);
        expect(notifications.shown, isEmpty);
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

    test('keeps existing reminders active when location is denied', () async {
      final location = _FakeLocationService(
        _pointAtMeters(200),
        status: LocationAccessStatus.permissionDenied,
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

      expect(controller.reminders.single.isTracking, isTrue);
      expect(controller.activeCount, 1);
      expect(controller.attentionAction, AttentionAction.requestLocation);
    });

    test('keeps a new reminder active when location is denied', () async {
      final location = _FakeLocationService(
        _pointAtMeters(200),
        status: LocationAccessStatus.permissionDenied,
      );
      final controller = AppController(
        repository: _FakeRepository([]),
        locationService: location,
        notificationService: _FakeNotificationService(),
      );
      addTearDown(() {
        controller.dispose();
        unawaited(location.close());
      });

      await controller.initialize();
      await controller.saveReminder(_reminder());

      expect(controller.reminders.single.isTracking, isTrue);
      expect(controller.activeCount, 1);
      expect(controller.attentionAction, AttentionAction.requestLocation);
    });

    test('activates a paused reminder when location is off', () async {
      final paused = _reminder().copy(isTracking: false);
      final location = _FakeLocationService(
        _pointAtMeters(200),
        status: LocationAccessStatus.serviceDisabled,
      );
      final controller = AppController(
        repository: _FakeRepository([paused]),
        locationService: location,
        notificationService: _FakeNotificationService(),
      );
      addTearDown(() {
        controller.dispose();
        unawaited(location.close());
      });

      await controller.initialize();
      await controller.setReminderTracking(paused, true);

      expect(controller.reminders.single.isTracking, isTrue);
      expect(controller.activeCount, 1);
      expect(controller.attentionAction, AttentionAction.enableLocation);
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

  test('pins and unpins a reminder', () async {
    final harness = await _Harness.create([_reminder()]);
    addTearDown(harness.dispose);

    await harness.controller.setReminderPinned(harness.reminder, true);
    expect(harness.reminder.isPinned, isTrue);

    await harness.controller.setReminderPinned(harness.reminder, false);
    expect(harness.reminder.isPinned, isFalse);
  });

  test('loads and updates the Google Sans preference', () async {
    final repository = _FakeRepository([]).._useGoogleSans = true;
    final location = _FakeLocationService(_pointAtMeters(200));
    final controller = AppController(
      repository: repository,
      locationService: location,
      notificationService: _FakeNotificationService(),
    );
    addTearDown(() {
      controller.dispose();
      unawaited(location.close());
    });

    await controller.initialize();
    expect(controller.useGoogleSans, isTrue);

    await controller.setUseGoogleSans(false);
    expect(controller.useGoogleSans, isFalse);
    expect(repository._useGoogleSans, isFalse);
  });

  test(
    'keeps the background tracker synchronized with active reminders',
    () async {
      final tracking = _FakeBackgroundTracking();
      final harness = await _Harness.create(
        [_reminder()],
        backgroundTracking: tracking,
        backgroundTrackingEnabled: true,
        backgroundPermission: true,
      );
      addTearDown(harness.dispose);
      await _waitFor(() => tracking.starts == 1);

      await harness.controller.saveReminder(
        harness.reminder.copy(title: 'Updated station'),
      );
      await _waitFor(
        () => tracking.snapshots.any(
          (snapshot) => snapshot.single.title == 'Updated station',
        ),
      );

      await harness.controller.setReminderTracking(harness.reminder, false);
      await _waitFor(() => tracking.stops == 1);

      await harness.controller.setReminderTracking(harness.reminder, true);
      expect(tracking.starts, 2);
    },
  );

  test('enables optional background tracking independently', () async {
    final tracking = _FakeBackgroundTracking();
    final harness = await _Harness.create([
      _reminder(),
    ], backgroundTracking: tracking);
    addTearDown(harness.dispose);

    expect(harness.controller.backgroundTrackingEnabled, isFalse);
    expect(await harness.controller.setBackgroundTrackingEnabled(true), isTrue);
    expect(harness.controller.backgroundTrackingEnabled, isTrue);
    expect(tracking.starts, 1);

    expect(
      await harness.controller.setBackgroundTrackingEnabled(false),
      isTrue,
    );
    expect(harness.controller.backgroundTrackingEnabled, isFalse);
    expect(tracking.stops, greaterThanOrEqualTo(1));
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
    required this.repository,
    required this.location,
    required this.notifications,
  });

  final AppController controller;
  final _FakeRepository repository;
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
    BackgroundTrackingControl? backgroundTracking,
    bool backgroundTrackingEnabled = false,
    bool backgroundPermission = false,
  }) async {
    final repository = _FakeRepository(reminders)
      .._backgroundTrackingEnabled = backgroundTrackingEnabled;
    final location = _FakeLocationService(
      _pointAtMeters(initialMeters),
      backgroundPermission: backgroundPermission,
    );
    final notifications = _FakeNotificationService();
    final controller = AppController(
      repository: repository,
      locationService: location,
      notificationService: notifications,
      backgroundTracking: backgroundTracking,
    );
    await controller.initialize();
    await _waitFor(() => controller.currentPosition != null);
    return _Harness(
      controller: controller,
      repository: repository,
      location: location,
      notifications: notifications,
    );
  }

  Future<void> dispose() async {
    controller.dispose();
    await location.close();
  }
}

class _FakeBackgroundTracking implements BackgroundTrackingControl {
  int starts = 0;
  int stops = 0;
  final List<List<Reminder>> snapshots = [];

  @override
  Future<void> start({
    required List<Reminder> reminders,
    required bool alarmEnabled,
  }) async {
    starts++;
    snapshots.add(List.of(reminders));
  }

  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  Future<void> sync({
    required List<Reminder> reminders,
    required bool alarmEnabled,
  }) async {
    snapshots.add(List.of(reminders));
  }
}

class _FakeRepository implements AppRepository {
  _FakeRepository(Iterable<Reminder> reminders)
    : _reminders = {for (final reminder in reminders) reminder.id: reminder};

  final Map<String, Reminder> _reminders;
  String _themeMode = 'system';
  bool _alarmEnabled = true;
  bool _backgroundTrackingEnabled = false;
  bool _useGoogleSans = false;
  int saveFailuresRemaining = 0;

  @override
  Future<void> deleteReminder(String id) async {
    _reminders.remove(id);
  }

  @override
  bool loadAlarmEnabled() => _alarmEnabled;

  @override
  bool loadBackgroundTrackingEnabled() => _backgroundTrackingEnabled;

  @override
  bool loadUseGoogleSans() => _useGoogleSans;

  @override
  List<Reminder> loadReminders() => List.of(_reminders.values);

  @override
  String loadThemeMode() => _themeMode;

  @override
  Future<void> saveAlarmEnabled(bool value) async {
    _alarmEnabled = value;
  }

  @override
  Future<void> saveBackgroundTrackingEnabled(bool value) async {
    _backgroundTrackingEnabled = value;
  }

  @override
  Future<void> saveReminder(Reminder reminder) async {
    if (saveFailuresRemaining > 0) {
      saveFailuresRemaining--;
      throw StateError('save failed');
    }
    _reminders[reminder.id] = reminder;
  }

  @override
  Future<void> saveThemeMode(String value) async {
    _themeMode = value;
  }

  @override
  Future<void> saveUseGoogleSans(bool value) async {
    _useGoogleSans = value;
  }
}

class _FakeLocationService implements LocationService {
  _FakeLocationService(
    this.currentPoint, {
    this.status = LocationAccessStatus.ready,
    this.backgroundPermission = false,
  });

  final StreamController<Point> _updates = StreamController<Point>.broadcast();
  Point currentPoint;
  LocationAccessStatus status;
  bool backgroundPermission;
  int appSettingsOpens = 0;
  int locationSettingsOpens = 0;

  @override
  Future<LocationAccessStatus> accessStatus({bool background = true}) async =>
      status;

  @override
  Future<Point> current() async => currentPoint;

  @override
  Future<void> ensurePermission({bool background = false}) async {
    if (status != LocationAccessStatus.ready) {
      throw const LocationException('Location access is unavailable.');
    }
  }

  @override
  Future<bool> hasBackgroundPermission() async => backgroundPermission;

  @override
  Stream<Point> get updates => _updates.stream;

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
  int showFailuresRemaining = 0;

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
    if (showFailuresRemaining > 0) {
      showFailuresRemaining--;
      throw StateError('notification failed');
    }
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
