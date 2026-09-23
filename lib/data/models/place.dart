import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:loc/data/models/point.dart';

part 'place.g.dart';

@HiveType(typeId: 2)
class Place {
  @HiveField(0)
  final Point position;
  @HiveField(1)
  final int? radius;
  @HiveField(2)
  final String? displayName;

  Place({
    required this.position,
    this.radius = 500,
    this.displayName = 'Dropped pin',
  });

  Place copy({Point? position, int? radius, String? displayName}) {
    return Place(
      position: position ?? this.position,
      radius: radius ?? this.radius,
      displayName: displayName ?? this.displayName,
    );
  }

  factory Place.fromJson(Map<String, dynamic> json) => Place(
    position: Point.fromJson(json),
    radius: json['radius'] as int? ?? 500,
    displayName: json['display_name'] as String? ?? 'Dropped pin',
  );

  Map<String, dynamic> toJson() {
    return {
      'position': Point(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
      'radius': radius,
      'display_name': displayName,
    };
  }

  bool isSameLocation(Place other, {double toleranceMeters = 25}) =>
      Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        other.position.latitude,
        other.position.longitude,
      ) <=
      toleranceMeters;

  @override
  bool operator ==(Object other) =>
      other is Place && other.position == position;

  @override
  int get hashCode => position.hashCode;

  @override
  String toString() {
    String reminderStr = '{';
    reminderStr = '$reminderStr\n  "position": $position,';
    reminderStr = '$reminderStr\n  "radius": $radius,';
    reminderStr = '$reminderStr\n  "display_name": "$displayName",';
    reminderStr = '$reminderStr\n}';
    return reminderStr;
  }
}
