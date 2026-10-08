import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loc/data/app_repository.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/notification_service.dart';
import 'package:loc/l10n/app_localizations.dart';
import 'package:loc/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notification used by the background foreground-service. It must stay
/// distinct from [NotificationService.arrivalNotificationId].
const backgroundServiceNotificationId = 112233;
const _trackingSnapshotKey = 'backgroundTrackingSnapshot';

/// UI-side control for the background tracker.
///
/// The default [NoopBackgroundTrackingControl] keeps unit tests hermetic
/// (no platform channels). Production passes [FlutterBackgroundTrackingControl].
abstract class BackgroundTrackingControl {
  Future<void> start({
    required List<Reminder> reminders,
    required bool alarmEnabled,
    required String localeCode,
  });

  Future<void> stop();

  Future<void> sync({
    required List<Reminder> reminders,
    required bool alarmEnabled,
    required String localeCode,
  });
}

class NoopBackgroundTrackingControl implements BackgroundTrackingControl {
  @override
  Future<void> start({
    required List<Reminder> reminders,
    required bool alarmEnabled,
    String localeCode = 'en',
  }) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> sync({
    required List<Reminder> reminders,
    required bool alarmEnabled,
    String localeCode = 'en',
  }) async {}
}

class FlutterBackgroundTrackingControl implements BackgroundTrackingControl {
  FlutterBackgroundTrackingControl([FlutterBackgroundService? service])
    : _service = service ?? FlutterBackgroundService();

  final FlutterBackgroundService _service;

  @override
  Future<void> start({
    required List<Reminder> reminders,
    required bool alarmEnabled,
    required String localeCode,
  }) async {
    try {
      await _persistSnapshot(reminders, alarmEnabled, localeCode);
      if (await _service.isRunning()) {
        _sendSnapshot(reminders, alarmEnabled, localeCode);
        return;
      }
      final ready = _service
          .on('ready')
          .first
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      await _service.startService();
      await ready;
      _sendSnapshot(reminders, alarmEnabled, localeCode);
    } on Object {
      // Tracking still works in the foreground UI isolate; the background
      // service is a best-effort upgrade for screen-off tracking.
    }
  }

  @override
  Future<void> stop() async {
    try {
      if (await _service.isRunning()) _service.invoke('stopTracking');
    } on Object {
      // Ignore: foreground tracking already stopped.
    }
  }

  @override
  Future<void> sync({
    required List<Reminder> reminders,
    required bool alarmEnabled,
    required String localeCode,
  }) async {
    try {
      await _persistSnapshot(reminders, alarmEnabled, localeCode);
      if (await _service.isRunning()) {
        _sendSnapshot(reminders, alarmEnabled, localeCode);
      }
    } on Object {
      // Ignore: the persisted snapshot is read when the service restarts.
    }
  }

  void _sendSnapshot(
    List<Reminder> reminders,
    bool alarmEnabled,
    String localeCode,
  ) {
    _service.invoke('sync', {
      'alarmEnabled': alarmEnabled,
      'localeCode': localeCode,
      'reminders': reminders.map(_reminderToJson).toList(growable: false),
    });
  }

  Future<void> _persistSnapshot(
    List<Reminder> reminders,
    bool alarmEnabled,
    String localeCode,
  ) => _writeSnapshot(
    SharedPreferencesAsync(),
    reminders: reminders,
    alarmEnabled: alarmEnabled,
    localeCode: localeCode,
  );
}

/// Applies arrival state written after the UI isolate was destroyed.
Future<void> reconcileBackgroundTracking(AppRepository repository) async {
  final snapshot = await _readSnapshot(SharedPreferencesAsync());
  if (snapshot == null) return;
  final backgroundById = {
    for (final reminder in snapshot.reminders) reminder.id: reminder,
  };
  for (final reminder in repository.loadReminders()) {
    final background = backgroundById[reminder.id];
    if (!reminder.isTracking || background?.isTracking != true) continue;
    if (reminder.isArrived == background!.isArrived &&
        reminder.isAcknowledged == background.isAcknowledged) {
      continue;
    }
    await repository.saveReminder(
      reminder.copy(
        isArrived: background.isArrived,
        isAcknowledged: background.isAcknowledged,
      ),
    );
  }
}

/// Must be called from `main()` (UI isolate) before `runApp`.
Future<void> initializeBackgroundTracking() async {
  final snapshot = await _readSnapshot(SharedPreferencesAsync());
  final l10n = await loadAppLocalizations(snapshot?.localeCode);
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(autoStart: false),
    androidConfiguration: AndroidConfiguration(
      onStart: trackingServiceEntry,
      autoStart: false,
      autoStartOnBoot: false,
      isForegroundMode: true,
      initialNotificationTitle: l10n.backgroundTrackingNotificationTitle,
      initialNotificationContent: l10n.backgroundTrackingNotificationBody,
      // ignore: avoid_redundant_argument_values
      foregroundServiceNotificationId: backgroundServiceNotificationId,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
  );
}

/// Background-isolate entrypoint used while the app task remains active.
/// Declared top-level with an entry-point pragma so the Android background
/// engine can find it after tree-shaking.
@pragma('vm:entry-point')
Future<void> trackingServiceEntry(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final preferences = SharedPreferencesAsync();
  final initialSnapshot = await _readSnapshot(preferences);
  var l10n = await loadAppLocalizations(initialSnapshot?.localeCode);
  final notificationContent = NotificationContent.fromLocalizations(l10n);
  final notifications = FlutterLocalNotificationsPlugin();
  await notifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
    ),
  );
  await NotificationService.createChannels(notifications, notificationContent);

  // A stale service may briefly be restored by an older installation.
  if (initialSnapshot == null ||
      !initialSnapshot.reminders.any((item) => item.isTracking)) {
    await _stop(service);
    return;
  }

  if (service is AndroidServiceInstance) {
    await service.setAsForegroundService();
    await service.setAutoStartOnBootMode(false);
  }

  var reminders = initialSnapshot.reminders;
  var alarmEnabled = initialSnapshot.alarmEnabled;
  var localeCode = initialSnapshot.localeCode;
  Point? previous;
  String? signature;
  StreamSubscription<Position>? subscription;

  Future<void> handlePosition(Position position) async {
    final point = Point(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    if (!reminders.any((item) => item.isTracking)) {
      signature = null;
      await notifications.cancel(id: NotificationService.arrivalNotificationId);
      await _stop(service);
      return;
    }
    for (var index = 0; index < reminders.length; index++) {
      final reminder = reminders[index];
      if (!reminder.isTracking) continue;
      final entered =
          reminder.hasArrived(point) ||
          (previous != null &&
              reminder.pathIntersectsArrivalZone(previous!, point));
      final arrived = reminder.isArrived ? !reminder.hasExited(point) : entered;
      final resetAck = !arrived && reminder.isAcknowledged;
      if (arrived == reminder.isArrived && !resetAck) continue;
      final updated = reminder.copy(
        isArrived: arrived,
        isAcknowledged: arrived ? reminder.isAcknowledged : false,
      );
      reminders[index] = updated;
      await _writeSnapshot(
        preferences,
        reminders: reminders,
        alarmEnabled: alarmEnabled,
        localeCode: localeCode,
      );
    }
    previous = point;
    await _syncAlert(reminders, alarmEnabled, notifications, l10n, (value) {
      signature = value;
    }, signature);
  }

  subscription =
      Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          forceLocationManager: true,
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
          intervalDuration: const Duration(seconds: 2),
        ),
      ).listen(
        handlePosition,
        onError: (Object _) async {
          // Keep the service alive; the next fix retries automatically.
        },
      );

  service.on('sync').listen((data) async {
    if (data != null) {
      final encoded = data['reminders'];
      if (encoded is List) {
        reminders = encoded
            .whereType<Map<Object?, Object?>>()
            .map((value) => _reminderFromJson(Map<String, dynamic>.from(value)))
            .toList();
      }
      final enabled = data['alarmEnabled'];
      if (enabled is bool) alarmEnabled = enabled;
      final locale = data['localeCode'];
      if (locale is String) {
        localeCode = locale;
        l10n = await loadAppLocalizations(localeCode);
        await NotificationService.createChannels(
          notifications,
          NotificationContent.fromLocalizations(l10n),
        );
      }
      await _writeSnapshot(
        preferences,
        reminders: reminders,
        alarmEnabled: alarmEnabled,
        localeCode: localeCode,
      );
    }
    if (!reminders.any((item) => item.isTracking)) {
      signature = null;
      await notifications.cancel(id: NotificationService.arrivalNotificationId);
      await subscription?.cancel();
      await _stop(service);
    } else {
      await _syncAlert(reminders, alarmEnabled, notifications, l10n, (value) {
        signature = value;
      }, signature);
    }
  });

  service.on('stopTracking').listen((_) async {
    await subscription?.cancel();
    await _stop(service);
  });

  service.on('dismissArrival').listen((_) async {
    for (var index = 0; index < reminders.length; index++) {
      final reminder = reminders[index];
      if (reminder.isArrived && !reminder.isAcknowledged) {
        final updated = reminder.copy(isAcknowledged: true);
        reminders[index] = updated;
      }
    }
    await _writeSnapshot(
      preferences,
      reminders: reminders,
      alarmEnabled: alarmEnabled,
      localeCode: localeCode,
    );
    signature = null;
    await notifications.cancel(id: NotificationService.arrivalNotificationId);
  });
  service.invoke('ready');
}

Future<void> _stop(ServiceInstance service) => service.stopSelf();

Future<void> _syncAlert(
  List<Reminder> reminders,
  bool alarmEnabled,
  FlutterLocalNotificationsPlugin notifications,
  AppLocalizations l10n,
  void Function(String?) setSignature,
  String? signature,
) async {
  final arrived = reminders
      .where(
        (item) => item.isTracking && item.isArrived && !item.isAcknowledged,
      )
      .toList();
  if (!alarmEnabled || arrived.isEmpty) {
    setSignature(null);
    await notifications.cancel(id: NotificationService.arrivalNotificationId);
    return;
  }
  final next = arrived
      .map((item) => '${item.id}:${item.title}:${item.alertStyle.name}')
      .join('|');
  if (next == signature) return;
  final android = notifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  if (await android?.areNotificationsEnabled() == false) return;
  final isAlarm = arrived.any((item) => item.isAlarm);
  final isVibration = arrived.any((item) => item.isVibration);
  if (signature != null || isAlarm) {
    await notifications.cancel(id: NotificationService.arrivalNotificationId);
  }
  await notifications.show(
    id: NotificationService.arrivalNotificationId,
    title: l10n.arrivalNotificationTitle,
    body: arrived.map((item) => item.title).join(', '),
    notificationDetails: NotificationService.arrivalDetails(
      isAlarm: isAlarm,
      isVibration: isVibration,
      content: NotificationContent.fromLocalizations(l10n),
    ),
  );
  setSignature(next);
}

Map<String, dynamic> _reminderToJson(Reminder reminder) => {
  'id': reminder.id,
  'title': reminder.title,
  'latitude': reminder.place.position.latitude,
  'longitude': reminder.place.position.longitude,
  'radius': reminder.place.radius,
  'displayName': reminder.place.displayName,
  'isTracking': reminder.isTracking,
  'isArrived': reminder.isArrived,
  'isAcknowledged': reminder.isAcknowledged,
  'isAlarm': reminder.isAlarm,
  'isVibration': reminder.isVibration,
  'isPinned': reminder.isPinned,
};

Reminder _reminderFromJson(Map<String, dynamic> json) => Reminder(
  id: json['id'] as String,
  title: json['title'] as String,
  place: Place(
    position: Point(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    ),
    radius: json['radius'] as int?,
    displayName: json['displayName'] as String?,
  ),
  isTracking: json['isTracking'] as bool,
  isArrived: json['isArrived'] as bool,
  isAcknowledged: json['isAcknowledged'] as bool,
  isAlarm: json['isAlarm'] as bool,
  isVibration: json['isVibration'] as bool,
  isPinned: json['isPinned'] as bool,
);

Future<void> _writeSnapshot(
  SharedPreferencesAsync preferences, {
  required List<Reminder> reminders,
  required bool alarmEnabled,
  required String localeCode,
}) => preferences.setString(
  _trackingSnapshotKey,
  jsonEncode({
    'alarmEnabled': alarmEnabled,
    'localeCode': localeCode,
    'reminders': reminders.map(_reminderToJson).toList(growable: false),
  }),
);

Future<({List<Reminder> reminders, bool alarmEnabled, String localeCode})?>
_readSnapshot(SharedPreferencesAsync preferences) async {
  try {
    final encoded = await preferences.getString(_trackingSnapshotKey);
    if (encoded == null) return null;
    final value = jsonDecode(encoded);
    if (value is! Map<String, dynamic>) return null;
    final reminders = value['reminders'];
    final alarmEnabled = value['alarmEnabled'];
    final localeCode = value['localeCode'];
    if (reminders is! List || alarmEnabled is! bool) return null;
    return (
      reminders: reminders
          .whereType<Map<String, dynamic>>()
          .map(_reminderFromJson)
          .toList(),
      alarmEnabled: alarmEnabled,
      localeCode: localeCode == 'ar' ? 'ar' : 'en',
    );
  } on Object {
    return null;
  }
}
