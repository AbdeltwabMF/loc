import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';

part 'reminder.g.dart';

@HiveType(typeId: 1)
class Reminder {
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String title;
  @HiveField(2)
  late Place place;
  @HiveField(3)
  late double initialDistance;
  @HiveField(4)
  late bool isTracking;
  @HiveField(5)
  late bool isArrived;
  @HiveField(6)
  String? notes = '';

  Reminder({
    required this.id,
    required this.title,
    required this.place,
    required this.initialDistance,
    required this.isTracking,
    required this.isArrived,
    this.notes,
  });

  Reminder.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    title = json['title'] as String;
    place = json['place'] as Place;
    initialDistance = json['initialDistance'] as double;
    isTracking = json['isTracking'] as bool;
    isArrived = json['isArrived'] as bool;
    notes = json['notes'] as String;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'place': place,
      'initialDistance': initialDistance,
      'isTracking': isTracking,
      'isArrived': isArrived,
      'notes': notes,
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
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      place: place ?? this.place,
      initialDistance: initialDistance ?? this.initialDistance,
      isTracking: isTracking ?? this.isTracking,
      isArrived: isArrived ?? this.isArrived,
      notes: notes ?? this.notes,
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
    reminderStr = '$reminderStr\n}';
    return reminderStr;
  }

  double remainderDistance(Point current) {
    double inMeters = Geolocator.distanceBetween(current.latitude,
        current.longitude, place.position.latitude, place.position.longitude);
    return inMeters;
  }

  double bearing(Point current) {
    double inDegrees = Geolocator.bearingBetween(current.latitude,
        current.longitude, place.position.latitude, place.position.longitude);
    return inDegrees;
  }

  double traveledDistance(Point current) {
    double remainder = remainderDistance(current);
    if (initialDistance < remainder) initialDistance = remainder;

    return (initialDistance - remainder);
  }

  double? traveledDistancePercent(Point current) {
    double traveled = traveledDistance(current);
    if (initialDistance == 0.0) return 1;
    return (traveled / initialDistance);
  }
}
