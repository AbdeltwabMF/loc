import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:loc/data/app_repository.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/app_locale_service.dart';
import 'package:loc/data/services/background_tracking_service.dart';
import 'package:loc/data/services/location_service.dart';
import 'package:loc/data/services/notification_service.dart';
import 'package:loc/l10n/app_localizations.dart';
import 'package:loc/l10n/l10n.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this._repository,
    required this._locationService,
    required this._notificationService,
    BackgroundTrackingControl? backgroundTracking,
  }) : _backgroundTracking =
           backgroundTracking ?? NoopBackgroundTrackingControl();

  final AppRepository _repository;
  final LocationService _locationService;
  final NotificationService _notificationService;
  final BackgroundTrackingControl _backgroundTracking;
  final List<Reminder> _reminders = [];
  String? _arrivalNotificationSignature;
  StreamSubscription<Point>? _positionSubscription;
  Future<void> _operationQueue = Future.value();
  Point? _currentPosition;
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  late AppLocalizations _l10n;
  bool _useSystemFont = false;
  bool _alarmEnabled = true;
  bool _notificationsAllowed = true;
  bool _backgroundTrackingPreferred = false;
  bool _backgroundLocationAllowed = false;
  bool _trackingSetupSeen = false;
  bool _permissionRecoveryRequired = false;
  bool _isTrackingLocation = false;
  bool _isStartingTracking = false;
  bool _isDisposed = false;
  String? _locationError;

  List<Reminder> get reminders => List.unmodifiable(_reminders);
  Point? get currentPosition => _currentPosition;
  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  String get effectiveLanguageCode {
    final code =
        _locale?.languageCode ??
        PlatformDispatcher.instance.locale.languageCode;
    return code == 'ar' ? 'ar' : 'en';
  }

  bool get useSystemFont => _useSystemFont;
  bool get alarmEnabled => _alarmEnabled;
  bool get notificationsAllowed => _notificationsAllowed;
  bool get systemNotificationsEnabled => _alarmEnabled && _notificationsAllowed;
  bool get backgroundTrackingEnabled =>
      _backgroundTrackingPreferred && _backgroundLocationAllowed;
  bool get backgroundLocationAllowed => _backgroundLocationAllowed;
  bool get trackingSetupSeen => _trackingSetupSeen;
  bool get permissionRecoveryRequired => _permissionRecoveryRequired;
  bool get permissionPageOpen =>
      !_trackingSetupSeen || _permissionRecoveryRequired;
  bool get isTrackingLocation => _isTrackingLocation;
  String? get locationError => _locationError;

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
    _themeMode = switch (_repository.loadThemeMode()) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final localeCode = _repository.loadLocaleCode();
    _locale = localeCode == null ? null : Locale(localeCode);
    _l10n = await loadAppLocalizations(effectiveLanguageCode);
    await _notificationService.updateLocalization(
      NotificationContent.fromLocalizations(_l10n),
    );
    _useSystemFont = _repository.loadUseSystemFont();
    _trackingSetupSeen = _repository.loadTrackingSetupSeen();
    _alarmEnabled = _repository.loadAlarmEnabled();
    _notificationsAllowed = await _notificationService.isPermissionGranted();
    _backgroundTrackingPreferred = _repository.loadBackgroundTrackingEnabled();
    _backgroundLocationAllowed = await _locationService
        .hasBackgroundPermission();
    if (!backgroundTrackingEnabled || permissionPageOpen) {
      await _backgroundTracking.stop();
    }

    if (activeCount > 0) {
      await _refreshTrackingAccess(startTrackingWhenReady: true);
      if (!permissionPageOpen) unawaited(_reconcileInitialPosition());
    } else {
      await _backgroundTracking.stop();
      await _syncArrivalAlert();
    }
    notifyListeners();
  }

  Future<void> _reconcileInitialPosition() async {
    Point point;
    try {
      point = await _locationService.current();
    } on Object {
      if (_isDisposed) return;
      try {
        await _enqueue(_syncArrivalAlert);
      } on Object {
        // A later location update will retry notification reconciliation.
      }
      return;
    }
    if (_isDisposed) return;
    try {
      await _enqueue(() => _handlePosition(point));
    } on Object {
      // The live location stream remains the source of subsequent updates.
    }
  }

  Future<void> startTracking({bool requestPermission = true}) async {
    if (_positionSubscription != null || _isStartingTracking) return;
    _isStartingTracking = true;
    try {
      if (requestPermission) {
        await _locationService.ensurePermission();
      }
      _locationError = null;
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
              notifyListeners();
            }),
          );
        },
        cancelOnError: true,
        onError: (Object error, StackTrace stackTrace) {
          _locationError = error.toString();
          _isTrackingLocation = false;
          _positionSubscription = null;
          notifyListeners();
          unawaited(
            _refreshTrackingAccess(
              startTrackingWhenReady: true,
              fallbackError: error.toString(),
            ),
          );
        },
        onDone: () {
          _isTrackingLocation = false;
          _positionSubscription = null;
          notifyListeners();
        },
      );
      if (backgroundTrackingEnabled) {
        unawaited(
          _backgroundTracking.start(
            reminders: _reminders,
            alarmEnabled: systemNotificationsEnabled,
            localeCode: effectiveLanguageCode,
          ),
        );
      }
    } on Object catch (error) {
      _isTrackingLocation = false;
      await _refreshTrackingAccess(
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
      if (activeCount == 0) _locationError = null;
      notifyListeners();
      return point;
    } on Object catch (error) {
      await _refreshTrackingAccess(
        startTrackingWhenReady: false,
        fallbackError: error.toString(),
      );
      notifyListeners();
      rethrow;
    }
  }

  Future<LocationAccessStatus> locationAccessStatus({
    bool background = false,
  }) => _locationService.accessStatus(background: background);

  Future<bool> requestForegroundLocation() async {
    final status = await locationAccessStatus();
    if (status == LocationAccessStatus.serviceDisabled) {
      await openLocationSettings();
      return false;
    }
    if (status == LocationAccessStatus.settingsRequired) {
      await openAppSettings();
      return false;
    }
    try {
      await _locationService.ensurePermission();
    } on Object {
      await refreshTrackingState();
      return false;
    }
    await refreshTrackingState();
    return await locationAccessStatus() == LocationAccessStatus.ready;
  }

  Future<bool> openLocationSettings() =>
      _locationService.openLocationSettings();

  Future<bool> openAppSettings() => _locationService.openAppSettings();

  Future<void> saveReminder(Reminder reminder) => _enqueue(() async {
    await _saveReminder(reminder);
    notifyListeners();
  });

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
      final alertStyleChanged = existing.alertStyle != reminder.alertStyle;
      savedReminder = reminder.copy(
        isArrived: isArrived,
        isAcknowledged: isArrived && !alertStyleChanged
            ? existing.isAcknowledged
            : false,
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
    await _backgroundTracking.sync(
      reminders: _reminders,
      alarmEnabled: systemNotificationsEnabled,
      localeCode: effectiveLanguageCode,
    );
    if (savedReminder.isTracking) {
      await _refreshTrackingAccess(startTrackingWhenReady: true);
    }
    await _syncArrivalAlert();
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
        if (!value) await _syncTrackingState();
        notifyListeners();
      });

  Future<void> setReminderPinned(Reminder reminder, bool value) =>
      _enqueue(() async {
        final index = _reminders.indexWhere((item) => item.id == reminder.id);
        if (index == -1 || _reminders[index].isPinned == value) return;
        final updated = _reminders[index].copy(isPinned: value);
        await _repository.saveReminder(updated);
        _reminders[index] = updated;
        await _backgroundTracking.sync(
          reminders: _reminders,
          alarmEnabled: systemNotificationsEnabled,
          localeCode: effectiveLanguageCode,
        );
        notifyListeners();
      });

  Future<void> setThemeMode(ThemeMode value) async {
    await _repository.saveThemeMode(value.name);
    _themeMode = value;
    notifyListeners();
  }

  Future<void> setLocale(Locale? value) async {
    final languageCode = value?.languageCode;
    if (languageCode != null && languageCode != 'en' && languageCode != 'ar') {
      return;
    }
    await _repository.saveLocaleCode(languageCode);
    _locale = value;
    _l10n = await loadAppLocalizations(effectiveLanguageCode);
    await AppLocaleService.setApplicationLocale(languageCode);
    await _notificationService.updateLocalization(
      NotificationContent.fromLocalizations(_l10n),
    );
    await _backgroundTracking.sync(
      reminders: _reminders,
      alarmEnabled: systemNotificationsEnabled,
      localeCode: effectiveLanguageCode,
    );
    _arrivalNotificationSignature = null;
    await _syncArrivalAlert();
    notifyListeners();
  }

  Future<void> setUseSystemFont(bool value) async {
    await _repository.saveUseSystemFont(value);
    _useSystemFont = value;
    notifyListeners();
  }

  Future<void> refreshSystemLocale() async {
    if (_locale != null || _isDisposed) return;
    _l10n = await loadAppLocalizations(effectiveLanguageCode);
    await _notificationService.updateLocalization(
      NotificationContent.fromLocalizations(_l10n),
    );
    await _backgroundTracking.sync(
      reminders: _reminders,
      alarmEnabled: systemNotificationsEnabled,
      localeCode: effectiveLanguageCode,
    );
    _arrivalNotificationSignature = null;
    await _syncArrivalAlert();
    notifyListeners();
  }

  Future<void> markTrackingSetupSeen() async {
    if (_trackingSetupSeen) return;
    try {
      await _repository.saveTrackingSetupSeen(true);
      _trackingSetupSeen = true;
      _permissionRecoveryRequired = false;
      await _refreshTrackingAccess(startTrackingWhenReady: true);
      await _syncArrivalAlert();
      notifyListeners();
    } on Object {
      _trackingSetupSeen = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> completePermissionRecovery() async {
    if (!_permissionRecoveryRequired) return;
    _permissionRecoveryRequired = false;
    await _refreshTrackingAccess(startTrackingWhenReady: true);
    await _syncArrivalAlert();
    notifyListeners();
  }

  Future<bool> setAlarmEnabled(bool value) async {
    if (value && !_notificationsAllowed) {
      _notificationsAllowed = await _notificationService.requestPermission();
      if (!_notificationsAllowed) {
        notifyListeners();
        return false;
      }
    }
    await _repository.saveAlarmEnabled(value);
    _alarmEnabled = value;
    await _backgroundTracking.sync(
      reminders: _reminders,
      alarmEnabled: systemNotificationsEnabled,
      localeCode: effectiveLanguageCode,
    );
    if (!value) {
      _arrivalNotificationSignature = null;
      await _notificationService.dismissArrival();
    } else {
      await _syncArrivalAlert();
    }
    await _refreshTrackingAccess(startTrackingWhenReady: true);
    notifyListeners();
    return true;
  }

  Future<bool> setBackgroundTrackingEnabled(bool value) async {
    if (!value) {
      _backgroundTrackingPreferred = false;
      await _repository.saveBackgroundTrackingEnabled(false);
      await _backgroundTracking.stop();
      notifyListeners();
      return true;
    }
    try {
      await _locationService.ensurePermission(background: true);
    } on Object {
      _backgroundLocationAllowed = await _locationService
          .hasBackgroundPermission();
      notifyListeners();
      return false;
    }
    _backgroundLocationAllowed = true;
    _backgroundTrackingPreferred = true;
    await _repository.saveBackgroundTrackingEnabled(true);
    if (activeCount > 0 && !permissionPageOpen) {
      await _backgroundTracking.start(
        reminders: _reminders,
        alarmEnabled: systemNotificationsEnabled,
        localeCode: effectiveLanguageCode,
      );
    }
    notifyListeners();
    return true;
  }

  Future<void> refreshTrackingState() async {
    _notificationsAllowed = await _notificationService.isPermissionGranted();
    _backgroundLocationAllowed = await _locationService
        .hasBackgroundPermission();
    if (!backgroundTrackingEnabled) await _backgroundTracking.stop();
    await _refreshTrackingAccess(startTrackingWhenReady: true);
    notifyListeners();
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
    await _backgroundTracking.sync(
      reminders: _reminders,
      alarmEnabled: systemNotificationsEnabled,
      localeCode: effectiveLanguageCode,
    );
    notifyListeners();
  });

  Future<void> _handlePosition(Point point) async {
    if (_isDisposed) return;
    final previousPosition = _currentPosition;
    for (var index = 0; index < _reminders.length; index++) {
      final reminder = _reminders[index];
      if (!reminder.isTracking) continue;
      final enteredArrivalZone =
          reminder.hasArrived(point) ||
          (previousPosition != null &&
              reminder.pathIntersectsArrivalZone(previousPosition, point));
      final arrived = reminder.isArrived
          ? !reminder.hasExited(point)
          : enteredArrivalZone;
      final resetAcknowledgement = !arrived && reminder.isAcknowledged;
      if (arrived == reminder.isArrived && !resetAcknowledgement) {
        continue;
      }
      final updated = reminder.copy(
        isArrived: arrived,
        isAcknowledged: arrived ? reminder.isAcknowledged : false,
      );
      await _repository.saveReminder(updated);
      _reminders[index] = updated;
    }

    _currentPosition = point;
    await _syncArrivalAlert();
    _locationError = null;
    notifyListeners();
  }

  Future<void> _syncArrivalAlert() async {
    if (_isDisposed) return;
    final arrived = arrivedReminders;
    if (permissionPageOpen || !systemNotificationsEnabled || arrived.isEmpty) {
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
    final isAlarm = arrived.any((item) => item.isAlarm);
    if (_arrivalNotificationSignature != null || isAlarm) {
      await _notificationService.dismissArrival();
    }
    await _notificationService.showArrival(
      title: _l10n.arrivalNotificationTitle,
      body: arrived.map((item) => item.title).join(', '),
      isAlarm: isAlarm,
      isVibration: arrived.any((item) => item.isVibration),
    );
    _arrivalNotificationSignature = signature;
  }

  Future<void> _syncTrackingState() async {
    if (activeCount > 0) {
      if (backgroundTrackingEnabled && !permissionPageOpen) {
        await _backgroundTracking.start(
          reminders: _reminders,
          alarmEnabled: systemNotificationsEnabled,
          localeCode: effectiveLanguageCode,
        );
      } else {
        await _backgroundTracking.stop();
      }
      return;
    }
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTrackingLocation = false;
    _locationError = null;
    await _backgroundTracking.sync(
      reminders: _reminders,
      alarmEnabled: systemNotificationsEnabled,
      localeCode: effectiveLanguageCode,
    );
    await _backgroundTracking.stop();
  }

  Future<void> _refreshTrackingAccess({
    required bool startTrackingWhenReady,
    String? fallbackError,
  }) async {
    if (activeCount == 0) {
      _locationError = null;
      _permissionRecoveryRequired = false;
      return;
    }
    switch (await _locationService.accessStatus(background: false)) {
      case LocationAccessStatus.serviceDisabled:
        _locationError = _l10n.deviceLocationDisabledError;
        _permissionRecoveryRequired = true;
        await _pauseTrackingForPermissionPage();
        return;
      case LocationAccessStatus.permissionDenied:
        _locationError = _l10n.activeRemindersLocationRequiredError;
        _permissionRecoveryRequired = true;
        await _pauseTrackingForPermissionPage();
        return;
      case LocationAccessStatus.settingsRequired:
        _locationError = _l10n.enableActiveRemindersLocationError;
        _permissionRecoveryRequired = true;
        await _pauseTrackingForPermissionPage();
        return;
      case LocationAccessStatus.ready:
        _locationError = fallbackError;
        if (permissionPageOpen) {
          await _pauseTrackingForPermissionPage();
          return;
        }
        if (startTrackingWhenReady && _positionSubscription == null) {
          try {
            await startTracking(requestPermission: false);
          } on Object {
            // A later lifecycle refresh or location update retries tracking.
          }
        }
        return;
    }
  }

  Future<void> _pauseTrackingForPermissionPage() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTrackingLocation = false;
    _arrivalNotificationSignature = null;
    await _notificationService.dismissArrival();
    await _backgroundTracking.stop();
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
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_positionSubscription?.cancel());
    super.dispose();
  }
}
