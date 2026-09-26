import 'package:hive/hive.dart';
import 'package:loc/data/models/point.dart';

class Place {
  static const defaultRadius = 500;
  static const droppedPinLabel = 'Dropped pin';

  final Point position;
  final int? radius;
  final String? displayName;

  Place({
    required this.position,
    this.radius = defaultRadius,
    this.displayName = droppedPinLabel,
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
    radius: json['radius'] as int? ?? defaultRadius,
    displayName: json['display_name'] as String? ?? droppedPinLabel,
  );

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

// Type and field IDs are persisted and must never be reused.
class PlaceAdapter extends TypeAdapter<Place> {
  @override
  final int typeId = 2;

  @override
  Place read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var index = 0; index < fieldCount; index++)
        reader.readByte(): reader.read(),
    };
    return Place(
      position: fields[0] as Point,
      radius: fields[1] as int?,
      displayName: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Place object) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(object.position)
      ..writeByte(1)
      ..write(object.radius)
      ..writeByte(2)
      ..write(object.displayName);
  }
}
