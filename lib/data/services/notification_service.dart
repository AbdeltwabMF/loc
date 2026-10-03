import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const arrivalNotificationId = 4107;
  static const _androidFlagInsistent = 4;
  static const MethodChannel _settingsChannel = MethodChannel(
    'xyz.abdeltwab.loc/settings',
  );
  static const _permissionRequestedKey = 'notification_permission_requested';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('app_icon'),
      ),
    );
  }

  Future<bool> requestPermission() async {
    if (await isPermissionGranted()) return true;

    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_permissionRequestedKey) ?? false) {
      await _openNotificationSettings();
      return false;
    }
    await preferences.setBool(_permissionRequestedKey, true);

    final allowed = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    return allowed ?? true;
  }

  Future<void> _openNotificationSettings() async {
    try {
      await _settingsChannel.invokeMethod<void>('openNotificationSettings');
    } on Object {
      // The toggle remains off if Android cannot open the settings page.
    }
  }

  static Future<void> openAlarmSettings() async {
    try {
      await _settingsChannel.invokeMethod<void>(
        'openNotificationChannelSettings',
        'arrival_alarms_v2',
      );
    } on Object {
      // Android may not expose per-channel settings on every device.
    }
  }

  Future<bool> isPermissionGranted() async {
    final allowed = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.areNotificationsEnabled();
    return allowed ?? true;
  }

  Future<void> showArrival({
    required String title,
    required String body,
    required bool isAlarm,
    required bool isVibration,
  }) => _plugin.show(
    id: arrivalNotificationId,
    title: title,
    body: body,
    notificationDetails: arrivalDetails(
      isAlarm: isAlarm,
      isVibration: isVibration,
    ),
  );

  Future<void> dismissArrival() => _plugin.cancel(id: arrivalNotificationId);

  static NotificationDetails arrivalDetails({
    required bool isAlarm,
    required bool isVibration,
  }) => NotificationDetails(
    android: isAlarm
        ? AndroidNotificationDetails(
            'arrival_alarms_v2',
            'Arrival alarms',
            channelDescription:
                'Repeating alarms for destinations that must wake you.',
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.alarm,
            audioAttributesUsage: AudioAttributesUsage.alarm,
            sound: UriAndroidNotificationSound(
              'content://settings/system/alarm_alert',
            ),
            ongoing: true,
            autoCancel: false,
            additionalFlags: Int32List.fromList([_androidFlagInsistent]),
          )
        : isVibration
        ? AndroidNotificationDetails(
            'arrival_vibrations_v1',
            'Arrival vibrations',
            channelDescription:
                'Silent vibration alerts when an active destination is reached.',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
            playSound: false,
            vibrationPattern: Int64List.fromList([0, 400, 200, 400]),
          )
        : const AndroidNotificationDetails(
            'arrival_reminders_v2',
            'Arrival reminders',
            channelDescription:
                'Brief alerts when an active destination is reached.',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
          ),
  );
}
