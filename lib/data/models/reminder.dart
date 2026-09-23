import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';

part 'reminder.g.dart';

enum ReminderAlertStyle { brief, vibration, alarm }

@HiveType(typeId: 1)
class Reminder {
  static const arrivalExitBufferMeters = 25.0;

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final Place place;
  @HiveField(3)
  final double initialDistance;
  @HiveField(4)
  final bool isTracking;
  @HiveField(5)
  final bool isArrived;
  @HiveField(6)
  final String? notes;
  @HiveField(7, defaultValue: false)
  final bool isAcknowledged;
  @HiveField(8, defaultValue: false)
  final bool isAlarm;
  @HiveField(9, defaultValue: false)
  final bool isVibration;

  Reminder({
    required this.id,
    required this.title,
    required this.place,
    required this.initialDistance,
    required this.isTracking,
    required this.isArrived,
    this.notes,
    this.isAcknowledged = false,
    this.isAlarm = false,
    this.isVibration = false,
  });

  ReminderAlertStyle get alertStyle => isAlarm
      ? ReminderAlertStyle.alarm
      : isVibration
      ? ReminderAlertStyle.vibration
      : ReminderAlertStyle.brief;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'place': place,
      'initialDistance': initialDistance,
      'isTracking': isTracking,
      'isArrived': isArrived,
      'notes': notes,
      'isAcknowledged': isAcknowledged,
      'isAlarm': isAlarm,
      'isVibration': isVibration,
    };
  }

  Reminder copy({
    String? id,
    String? title,
    Place? place,
    double? initialDistance,
    bool? isTracking,
    bool? isArrived,
    String? notes,
    bool? isAcknowledged,
    bool? isAlarm,
    bool? isVibration,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      place: place ?? this.place,
      initialDistance: initialDistance ?? this.initialDistance,
      isTracking: isTracking ?? this.isTracking,
      isArrived: isArrived ?? this.isArrived,
      notes: notes ?? this.notes,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      isAlarm: isAlarm ?? this.isAlarm,
      isVibration: isVibration ?? this.isVibration,
    );
  }

  @override
  String toString() {
    String reminderStr = '{';
    reminderStr = '$reminderStr\n  "id": "$id",';
    reminderStr = '$reminderStr\n  "title": "$title",';
    reminderStr = '$reminderStr\n  "place": $place,';
    reminderStr = '$reminderStr\n  "initialDistance": $initialDistance,';
    reminderStr = '$reminderStr\n  "isTracking": $isTracking,';
    reminderStr = '$reminderStr\n  "isArrived": $isArrived,';
    reminderStr = '$reminderStr\n  "notes": "$notes",';
    reminderStr = '$reminderStr\n  "isAcknowledged": $isAcknowledged,';
    reminderStr = '$reminderStr\n  "isAlarm": $isAlarm,';
    reminderStr = '$reminderStr\n  "isVibration": $isVibration,';
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
      remainderDistance(current) <= (place.radius ?? 500);

  bool hasExited(Point current) =>
      remainderDistance(current) >
      (place.radius ?? 500) + arrivalExitBufferMeters;

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
    final radius = (place.radius ?? 500).toDouble();
    return closestX * closestX + closestY * closestY <= radius * radius;
  }

  double bearing(Point current) {
    final inDegrees = Geolocator.bearingBetween(
      current.latitude,
      current.longitude,
      place.position.latitude,
      place.position.longitude,
    );
    return inDegrees;
  }

  double traveledDistance(Point current) {
    return (initialDistance - remainderDistance(current))
        .clamp(0, double.infinity)
        .toDouble();
  }

  double? traveledDistancePercent(Point current) {
    if (initialDistance <= 0) return 0;
    return (traveledDistance(current) / initialDistance).clamp(0, 1).toDouble();
  }
}
