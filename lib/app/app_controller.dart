import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loc/data/app_repository.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/app_diagnostics.dart';
import 'package:loc/data/services/location_service.dart';
import 'package:loc/data/services/notification_service.dart';

enum AttentionAction {
  requestNotifications,
  enableLocation,
  requestLocation,
  openAppSettings,
  retry,
}

class AppController extends ChangeNotifier {
  AppController({
    required this._repository,
    required this._locationService,
    required this._notificationService,
  });

  final AppRepository _repository;
  final LocationService _locationService;
  final NotificationService _notificationService;
  final List<Reminder> _reminders = [];
  final List<Place> _savedPlaces = [];
  String? _arrivalNotificationSignature;
  StreamSubscription<Point>? _positionSubscription;
  Future<void> _operationQueue = Future.value();
  Point? _currentPosition;
  ThemeMode _themeMode = ThemeMode.system;
  bool _alarmEnabled = true;
  bool _isTrackingLocation = false;
  bool _isStartingTracking = false;
  bool _isDisposed = false;
  String? _locationError;
  AttentionAction? _attentionAction;

  List<Reminder> get reminders => List.unmodifiable(_reminders);
  List<Place> get savedPlaces => List.unmodifiable(_savedPlaces);
  Point? get currentPosition => _currentPosition;
  ThemeMode get themeMode => _themeMode;
  bool get alarmEnabled => _alarmEnabled;
  bool get isTrackingLocation => _isTrackingLocation;
  String? get locationError => _locationError;
  AttentionAction? get attentionAction => _attentionAction;
  String get attentionActionLabel => switch (_attentionAction) {
    AttentionAction.requestNotifications => 'Allow',
    AttentionAction.enableLocation => 'Turn on',
    AttentionAction.requestLocation => 'Allow',
    AttentionAction.openAppSettings => 'Open settings',
    AttentionAction.retry => 'Retry',
    null => '',
  };
  int get activeCount => _reminders.where((item) => item.isTracking).length;
  List<Reminder> get arrivedReminders => _reminders
      .where(
        (item) => item.isTracking && item.isArrived && !item.isAcknowledged,
      )
      .toList(growable: false);
  bool get hasArrivalAlert => arrivedReminders.isNotEmpty;

  Future<void> initialize() async {
    _reminders
      ..clear()
      ..addAll(_repository.loadReminders());
    _savedPlaces
      ..clear()
      ..addAll(_repository.loadSavedPlaces().toSet());
    _themeMode = switch (_repository.loadThemeMode()) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _alarmEnabled = _repository.loadAlarmEnabled();

    if (activeCount > 0) {
      await _refreshAttentionState(startTrackingWhenReady: true);
      if (_attentionAction == null) unawaited(_reconcileInitialPosition());
    } else {
      await _syncArrivalAlert();
    }
    notifyListeners();
  }

  Future<void> _reconcileInitialPosition() async {
    Point point;
    try {
      point = await _locationService.current();
    } on Object catch (error) {
      AppDiagnostics.record('location.initial', error);
      if (_isDisposed) return;
      try {
        await _enqueue(_syncArrivalAlert);
      } on Object catch (fallbackError) {
        AppDiagnostics.record('notification.initial', fallbackError);
      }
      return;
    }
    if (_isDisposed) return;
    try {
      await _enqueue(() => _handlePosition(point));
    } on Object catch (error) {
      AppDiagnostics.record('location.initial', error);
    }
  }

  Future<void> startTracking({bool requestPermission = true}) async {
    if (_positionSubscription != null || _isStartingTracking) return;
    _isStartingTracking = true;
    try {
      if (requestPermission) {
        await _locationService.ensurePermission(background: true);
      }
      if (requestPermission &&
          !await _notificationService.requestPermission()) {
        throw const LocationException(
          'Allow notifications so Loc can alert you on arrival.',
        );
      }
      _locationError = null;
      _attentionAction = null;
      _isTrackingLocation = true;
      notifyListeners();
      _positionSubscription = _locationService.updates.listen(
        (point) {
          unawaited(
            _enqueue(() => _handlePosition(point)).onError((
              Object error,
              StackTrace stackTrace,
            ) {
              _locationError = error.toString();
              _attentionAction = AttentionAction.retry;
              notifyListeners();
            }),
          );
        },
        cancelOnError: true,
        onError: (Object error, StackTrace stackTrace) {
          _locationError = error.toString();
          _attentionAction = AttentionAction.retry;
          _isTrackingLocation = false;
          _positionSubscription = null;
          notifyListeners();
        },
        onDone: () {
          _isTrackingLocation = false;
          _positionSubscription = null;
          notifyListeners();
        },
      );
    } on Object catch (error) {
      AppDiagnostics.record('location.tracking', error);
      _isTrackingLocation = false;
      await _refreshAttentionState(
        startTrackingWhenReady: false,
        fallbackError: error.toString(),
      );
      notifyListeners();
      rethrow;
    } finally {
      _isStartingTracking = false;
    }
  }

  Future<Point> getCurrentPosition() async {
    try {
      final point = await _locationService.current();
      _currentPosition = point;
      if (activeCount == 0) {
        _locationError = null;
        _attentionAction = null;
      }
      notifyListeners();
      return point;
    } on Object catch (error) {
      AppDiagnostics.record('location.current', error);
      await _refreshAttentionState(
        startTrackingWhenReady: false,
        fallbackError: error.toString(),
      );
      notifyListeners();
      rethrow;
    }
  }

  Future<void> saveReminder(Reminder reminder) =>
      _enqueue(() => _saveReminder(reminder));

  Future<void> _saveReminder(Reminder reminder) async {
    final position = _currentPosition;
    final index = _reminders.indexWhere((item) => item.id == reminder.id);
    final existing = index == -1 ? null : _reminders[index];
    var savedReminder = reminder;
    if (reminder.isTracking &&
        existing != null &&
        existing.isArrived &&
        existing.place == reminder.place) {
      final isArrived = position == null || !reminder.hasExited(position);
      savedReminder = reminder.copy(
        isArrived: isArrived,
        isAcknowledged: isArrived ? existing.isAcknowledged : false,
      );
    } else if (position != null && reminder.isTracking) {
      savedReminder = reminder.copy(
        isArrived: reminder.hasArrived(position),
        isAcknowledged: false,
      );
    }
    await _repository.saveReminder(savedReminder);
    if (index == -1) {
      _reminders.insert(0, savedReminder);
    } else {
      _reminders[index] = savedReminder;
    }
    if (savedReminder.isTracking) {
      try {
        await startTracking();
      } on Object {
        // The saved reminder remains visible with an actionable permission error.
      }
    }
    await _syncArrivalAlert();
    notifyListeners();
  }

  Future<void> deleteReminder(Reminder reminder) => _enqueue(() async {
    await _repository.deleteReminder(reminder.id);
    _reminders.removeWhere((item) => item.id == reminder.id);
    await _syncTrackingState();
    await _syncArrivalAlert();
    notifyListeners();
  });

  Future<void> setReminderTracking(Reminder reminder, bool value) =>
      _enqueue(() async {
        final updated = reminder.copy(
          isTracking: value,
          isArrived: value ? reminder.isArrived : false,
          isAcknowledged: value ? reminder.isAcknowledged : false,
        );
        await _saveReminder(updated);
        await _syncTrackingState();
      });

  Future<bool> addSavedPlace(Place place) => _enqueue(() async {
    if (_savedPlaces.any((item) => item.isSameLocation(place))) return false;
    await _repository.saveSavedPlace(place);
    _savedPlaces.add(place);
    notifyListeners();
    return true;
  });

  Future<void> deleteSavedPlace(Place place) => _enqueue(() async {
    await _repository.deleteSavedPlace(place);
    _savedPlaces.remove(place);
    notifyListeners();
  });

  Future<void> setThemeMode(ThemeMode value) async {
    await _repository.saveThemeMode(value.name);
    _themeMode = value;
    notifyListeners();
  }

  Future<void> setAlarmEnabled(bool value) async {
    await _repository.saveAlarmEnabled(value);
    _alarmEnabled = value;
    if (!value) {
      await dismissArrival();
    } else {
      await _syncArrivalAlert();
    }
    notifyListeners();
  }

  Future<void> refreshAttention() async {
    await _refreshAttentionState(startTrackingWhenReady: true);
    notifyListeners();
  }

  Future<void> resolveAttention() async {
    switch (_attentionAction) {
      case AttentionAction.requestNotifications:
        if (!await _notificationService.requestPermission()) {
          await _locationService.openAppSettings();
          return;
        }
        await refreshAttention();
        return;
      case AttentionAction.enableLocation:
        await _locationService.openLocationSettings();
        return;
      case AttentionAction.requestLocation:
        try {
          await startTracking();
        } on Object {
          // The refreshed banner presents the next required action.
        }
        return;
      case AttentionAction.openAppSettings:
        await _locationService.openAppSettings();
        return;
      case AttentionAction.retry:
        try {
          await startTracking(requestPermission: false);
        } on Object {
          // The refreshed banner presents the next required action.
        }
        return;
      case null:
        return;
    }
  }

  Future<void> dismissArrival() => _enqueue(() async {
    for (var index = 0; index < _reminders.length; index++) {
      final reminder = _reminders[index];
      if (!reminder.isArrived || reminder.isAcknowledged) continue;
      final updated = reminder.copy(isAcknowledged: true);
      await _repository.saveReminder(updated);
      _reminders[index] = updated;
    }
    _arrivalNotificationSignature = null;
    await _notificationService.dismissArrival();
    notifyListeners();
  });

  Future<void> _handlePosition(Point point) async {
    if (_isDisposed) return;
    final previousPosition = _currentPosition;
    _currentPosition = point;
    for (var index = 0; index < _reminders.length; index++) {
      final reminder = _reminders[index];
      if (!reminder.isTracking) continue;
      final distance = reminder.remainderDistance(point);
      final enteredArrivalZone =
          reminder.hasArrived(point) ||
          (previousPosition != null &&
              reminder.pathIntersectsArrivalZone(previousPosition, point));
      final arrived = reminder.isArrived
          ? !reminder.hasExited(point)
          : enteredArrivalZone;
      final needsInitialDistance = reminder.initialDistance <= 0;
      final resetAcknowledgement = !arrived && reminder.isAcknowledged;
      if (arrived == reminder.isArrived &&
          !needsInitialDistance &&
          !resetAcknowledgement) {
        continue;
      }
      final updated = reminder.copy(
        isArrived: arrived,
        isAcknowledged: arrived ? reminder.isAcknowledged : false,
        initialDistance: needsInitialDistance
            ? distance
            : reminder.initialDistance,
      );
      await _repository.saveReminder(updated);
      _reminders[index] = updated;
    }

    await _syncArrivalAlert();
    if (!_isDisposed) notifyListeners();
  }

  Future<void> _syncArrivalAlert() async {
    if (_isDisposed) return;
    final arrived = arrivedReminders;
    if (!_alarmEnabled || arrived.isEmpty) {
      _arrivalNotificationSignature = null;
      await _notificationService.dismissArrival();
      return;
    }

    final signature = arrived
        .map((item) => '${item.id}:${item.title}:${item.alertStyle.name}')
        .join('|');
    if (_arrivalNotificationSignature == signature) return;
    if (!await _notificationService.isPermissionGranted()) return;
    if (_isDisposed) return;
    await _notificationService.showArrival(
      title: 'You have arrived',
      body: arrived.map((item) => item.title).join(', '),
      isAlarm: arrived.any((item) => item.isAlarm),
      isVibration: arrived.any((item) => item.isVibration),
    );
    _arrivalNotificationSignature = signature;
  }

  Future<void> _syncTrackingState() async {
    if (activeCount > 0) return;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTrackingLocation = false;
    _locationError = null;
    _attentionAction = null;
  }

  Future<void> _refreshAttentionState({
    required bool startTrackingWhenReady,
    String? fallbackError,
  }) async {
    if (activeCount == 0) {
      _locationError = null;
      _attentionAction = null;
      return;
    }
    if (!await _notificationService.isPermissionGranted()) {
      _locationError = 'Allow notifications so Loc can alert you on arrival.';
      _attentionAction = AttentionAction.requestNotifications;
      return;
    }
    switch (await _locationService.accessStatus()) {
      case LocationAccessStatus.serviceDisabled:
        _locationError = 'Device location is turned off.';
        _attentionAction = AttentionAction.enableLocation;
        return;
      case LocationAccessStatus.permissionDenied:
        _locationError = 'Location access is required for active reminders.';
        _attentionAction = AttentionAction.requestLocation;
        return;
      case LocationAccessStatus.settingsRequired:
        _locationError =
            'Allow location all the time for screen-off reminders.';
        _attentionAction = AttentionAction.openAppSettings;
        return;
      case LocationAccessStatus.ready:
        _locationError = fallbackError;
        _attentionAction = fallbackError == null ? null : AttentionAction.retry;
        if (startTrackingWhenReady && _positionSubscription == null) {
          try {
            await startTracking(requestPermission: false);
          } on Object {
            // startTracking updates the attention state with the failure.
          }
        }
        return;
    }
  }

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = _operationQueue.then((_) => operation());
    _operationQueue = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return result;
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_positionSubscription?.cancel());
    unawaited(_notificationService.dismissArrival());
    super.dispose();
  }
}
