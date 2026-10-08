import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:loc/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationContent {
  const NotificationContent({
    required this.alarmChannelName,
    required this.alarmChannelDescription,
    required this.vibrationChannelName,
    required this.vibrationChannelDescription,
    required this.reminderChannelName,
    required this.reminderChannelDescription,
  });

  factory NotificationContent.fromLocalizations(AppLocalizations l10n) =>
      NotificationContent(
        alarmChannelName: l10n.arrivalAlarmsChannelName,
        alarmChannelDescription: l10n.arrivalAlarmsChannelDescription,
        vibrationChannelName: l10n.arrivalVibrationsChannelName,
        vibrationChannelDescription: l10n.arrivalVibrationsChannelDescription,
        reminderChannelName: l10n.arrivalRemindersChannelName,
        reminderChannelDescription: l10n.arrivalRemindersChannelDescription,
      );

  static const english = NotificationContent(
    alarmChannelName: 'Arrival alarms',
    alarmChannelDescription:
        'Repeating alarms for destinations that must wake you.',
    vibrationChannelName: 'Arrival vibrations',
    vibrationChannelDescription:
        'Silent vibration alerts when an active destination is reached.',
    reminderChannelName: 'Arrival reminders',
    reminderChannelDescription:
        'Brief alerts when an active destination is reached.',
  );

  final String alarmChannelName;
  final String alarmChannelDescription;
  final String vibrationChannelName;
  final String vibrationChannelDescription;
  final String reminderChannelName;
  final String reminderChannelDescription;
}

class NotificationService {
  static const arrivalNotificationId = 4107;
  static const alarmChannelId = 'arrival_alarms_v3';
  static const _alarmSound = UriAndroidNotificationSound(
    'content://settings/system/alarm_alert',
  );
  static const _androidFlagInsistent = 4;
  static const MethodChannel _settingsChannel = MethodChannel(
    'xyz.abdeltwab.loc/settings',
  );
  static const _permissionRequestedKey = 'notification_permission_requested';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  NotificationContent _content = NotificationContent.english;

  Future<void> initialize({NotificationContent? content}) async {
    if (content != null) _content = content;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('app_icon'),
      ),
    );
    await createChannels(_plugin, _content);
  }

  Future<void> updateLocalization(NotificationContent content) async {
    _content = content;
    await createChannels(_plugin, content);
  }

  static Future<void> createChannels(
    FlutterLocalNotificationsPlugin plugin,
    NotificationContent content,
  ) async {
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        alarmChannelId,
        content.alarmChannelName,
        description: content.alarmChannelDescription,
        importance: Importance.max,
        sound: _alarmSound,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        'arrival_vibrations_v1',
        content.vibrationChannelName,
        description: content.vibrationChannelDescription,
        importance: Importance.high,
        playSound: false,
        vibrationPattern: Int64List.fromList([0, 400, 200, 400]),
      ),
    );
    await android?.createNotificationChannel(
      AndroidNotificationChannel(
        'arrival_reminders_v2',
        content.reminderChannelName,
        description: content.reminderChannelDescription,
        importance: Importance.high,
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
      content: _content,
    ),
  );

  Future<void> dismissArrival() => _plugin.cancel(id: arrivalNotificationId);

  static NotificationDetails arrivalDetails({
    required bool isAlarm,
    required bool isVibration,
    NotificationContent content = NotificationContent.english,
  }) => NotificationDetails(
    android: isAlarm
        ? AndroidNotificationDetails(
            alarmChannelId,
            content.alarmChannelName,
            channelDescription: content.alarmChannelDescription,
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.alarm,
            audioAttributesUsage: AudioAttributesUsage.alarm,
            sound: _alarmSound,
            ongoing: true,
            autoCancel: false,
            additionalFlags: Int32List.fromList([_androidFlagInsistent]),
          )
        : isVibration
        ? AndroidNotificationDetails(
            'arrival_vibrations_v1',
            content.vibrationChannelName,
            channelDescription: content.vibrationChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
            playSound: false,
            vibrationPattern: Int64List.fromList([0, 400, 200, 400]),
          )
        : AndroidNotificationDetails(
            'arrival_reminders_v2',
            content.reminderChannelName,
            channelDescription: content.reminderChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
          ),
  );
}
