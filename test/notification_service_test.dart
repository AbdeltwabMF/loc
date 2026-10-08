import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loc/data/services/notification_service.dart';

void main() {
  test('alarm details use the dedicated alarm channel and audio stream', () {
    final android = NotificationService.arrivalDetails(
      isAlarm: true,
      isVibration: false,
    ).android!;

    expect(android.channelId, NotificationService.alarmChannelId);
    expect(android.importance, Importance.max);
    expect(android.priority, Priority.max);
    expect(android.category, AndroidNotificationCategory.alarm);
    expect(android.audioAttributesUsage, AudioAttributesUsage.alarm);
    expect(android.sound?.sound, 'content://settings/system/alarm_alert');
    expect(android.ongoing, isTrue);
    expect(android.autoCancel, isFalse);
    expect(android.additionalFlags, contains(4));
  });
}
