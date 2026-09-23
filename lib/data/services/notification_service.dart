import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
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
    final allowed = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    return allowed ?? true;
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
  }) => _plugin.show(
    id: _arrivalNotificationId,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
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
              additionalFlags: Int32List.fromList([4]),
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
    ),
  );

  Future<void> dismissArrival() => _plugin.cancel(id: _arrivalNotificationId);

  static const _arrivalNotificationId = 4107;
}
