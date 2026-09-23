import 'package:hive/hive.dart';

part 'point.g.dart';

@HiveType(typeId: 3)
class Point {
  @HiveField(0)
  final double latitude;
  @HiveField(1)
  final double longitude;

  Point({required this.latitude, required this.longitude});

  Point copy({double? latitude, double? longitude}) {
    return Point(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory Point.fromJson(Map<String, dynamic> json) => Point(
    latitude: double.parse(json['lat'] as String),
    longitude: double.parse(json['lon'] as String),
  );

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }

  @override
  bool operator ==(Object other) =>
      other is Point &&
      latitude == other.latitude &&
      longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() {
    String reminderStr = '{';
    reminderStr = '$reminderStr\n  "latitude": $latitude,';
    reminderStr = '$reminderStr\n  "longitude": $longitude,';
    reminderStr = '$reminderStr\n}';
    return reminderStr;
  }
}
