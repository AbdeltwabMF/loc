import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';

enum ReminderAlertStyle { brief, vibration, alarm }

class Reminder {
  static const arrivalExitBufferMeters = 25.0;

  final String id;
  final String title;
  final Place place;
  final bool isTracking;
  final bool isArrived;
  final bool isAcknowledged;
  final bool isAlarm;
  final bool isVibration;
  final bool isPinned;

  Reminder({
    required this.id,
    required this.title,
    required this.place,
    required this.isTracking,
    required this.isArrived,
    this.isAcknowledged = false,
    this.isAlarm = false,
    this.isVibration = false,
    this.isPinned = false,
  });

  ReminderAlertStyle get alertStyle => isAlarm
      ? ReminderAlertStyle.alarm
      : isVibration
      ? ReminderAlertStyle.vibration
      : ReminderAlertStyle.brief;

  Reminder copy({
    String? id,
    String? title,
    Place? place,
    bool? isTracking,
    bool? isArrived,
    bool? isAcknowledged,
    bool? isAlarm,
    bool? isVibration,
    bool? isPinned,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      place: place ?? this.place,
      isTracking: isTracking ?? this.isTracking,
      isArrived: isArrived ?? this.isArrived,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      isAlarm: isAlarm ?? this.isAlarm,
      isVibration: isVibration ?? this.isVibration,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  String toString() {
    String reminderStr = '{';
    reminderStr = '$reminderStr\n  "id": "$id",';
    reminderStr = '$reminderStr\n  "title": "$title",';
    reminderStr = '$reminderStr\n  "place": $place,';
    reminderStr = '$reminderStr\n  "isTracking": $isTracking,';
    reminderStr = '$reminderStr\n  "isArrived": $isArrived,';
    reminderStr = '$reminderStr\n  "isAcknowledged": $isAcknowledged,';
    reminderStr = '$reminderStr\n  "isAlarm": $isAlarm,';
    reminderStr = '$reminderStr\n  "isVibration": $isVibration,';
    reminderStr = '$reminderStr\n  "isPinned": $isPinned,';
    reminderStr = '$reminderStr\n}';
    return reminderStr;
  }

  double remainderDistance(Point current) {
    final inMeters = Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      place.position.latitude,
      place.position.longitude,
    );
    return inMeters;
  }

  bool hasArrived(Point current) =>
      remainderDistance(current) <= (place.radius ?? Place.defaultRadius);

  bool hasExited(Point current) =>
      remainderDistance(current) >
      (place.radius ?? Place.defaultRadius) + arrivalExitBufferMeters;

  bool pathIntersectsArrivalZone(Point from, Point to) {
    const earthRadius = 6371000.0;
    final destination = place.position;
    final latitudeScale = math.pi * earthRadius / 180;
    final longitudeScale =
        latitudeScale * math.cos(destination.latitude * math.pi / 180);
    final startX = (from.longitude - destination.longitude) * longitudeScale;
    final startY = (from.latitude - destination.latitude) * latitudeScale;
    final endX = (to.longitude - destination.longitude) * longitudeScale;
    final endY = (to.latitude - destination.latitude) * latitudeScale;
    final deltaX = endX - startX;
    final deltaY = endY - startY;
    final segmentLengthSquared = deltaX * deltaX + deltaY * deltaY;
    final progress = segmentLengthSquared == 0
        ? 0.0
        : (-(startX * deltaX + startY * deltaY) / segmentLengthSquared).clamp(
            0.0,
            1.0,
          );
    final closestX = startX + progress * deltaX;
    final closestY = startY + progress * deltaY;
    final radius = (place.radius ?? Place.defaultRadius).toDouble();
    return closestX * closestX + closestY * closestY <= radius * radius;
  }

  double bearing(Point current) {
    final inDegrees = Geolocator.bearingBetween(
      current.latitude,
      current.longitude,
      place.position.latitude,
      place.position.longitude,
    );
    return (inDegrees + 360) % 360;
  }
}

// Type and field IDs are persisted and must never be reused. Legacy fields 3
// (initial distance) and 6 (notes) are read and discarded; field 10 stores the
// pinned state.
class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 1;

  @override
  Reminder read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var index = 0; index < fieldCount; index++)
        reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String,
      title: fields[1] as String,
      place: fields[2] as Place,
      isTracking: fields[4] as bool,
      isArrived: fields[5] as bool,
      isAcknowledged: fields[7] as bool? ?? false,
      isAlarm: fields[8] as bool? ?? false,
      isVibration: fields[9] as bool? ?? false,
      isPinned: fields[10] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Reminder object) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(object.id)
      ..writeByte(1)
      ..write(object.title)
      ..writeByte(2)
      ..write(object.place)
      ..writeByte(4)
      ..write(object.isTracking)
      ..writeByte(5)
      ..write(object.isArrived)
      ..writeByte(7)
      ..write(object.isAcknowledged)
      ..writeByte(8)
      ..write(object.isAlarm)
      ..writeByte(9)
      ..write(object.isVibration)
      ..writeByte(10)
      ..write(object.isPinned);
  }
}
