import 'package:hive/hive.dart';

part 'point.g.dart';

@HiveType(typeId: 3)
class Point {
  @HiveField(0)
  late double latitude;
  @HiveField(1)
  late double longitude;

  Point({
    required this.latitude,
    required this.longitude,
  });

  Point copy({
    double? latitude,
    double? longitude,
  }) {
    return Point(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Point.fromJson(Map<String, dynamic> json) {
    latitude = double.parse(json['lat']);
    longitude = double.parse(json['lon']);
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    String reminderStr = '{';
    reminderStr = '$reminderStr\n  "latitude": $latitude,';
    reminderStr = '$reminderStr\n  "longitude": $longitude,';
    reminderStr = '$reminderStr\n}';
    return reminderStr;
  }
}
