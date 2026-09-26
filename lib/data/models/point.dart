import 'package:hive/hive.dart';

class Point {
  final double latitude;
  final double longitude;

  Point({required this.latitude, required this.longitude});

  factory Point.fromJson(Map<String, dynamic> json) => Point(
    latitude: double.parse(json['lat'] as String),
    longitude: double.parse(json['lon'] as String),
  );

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

// Type and field IDs are persisted and must never be reused.
class PointAdapter extends TypeAdapter<Point> {
  @override
  final int typeId = 3;

  @override
  Point read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var index = 0; index < fieldCount; index++)
        reader.readByte(): reader.read(),
    };
    return Point(latitude: fields[0] as double, longitude: fields[1] as double);
  }

  @override
  void write(BinaryWriter writer, Point object) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(object.latitude)
      ..writeByte(1)
      ..write(object.longitude);
  }
}
