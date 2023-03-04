import 'package:hive/hive.dart';
import 'package:loc/data/models/point.dart';

part 'place.g.dart';

@HiveType(typeId: 2)
class Place {
  @HiveField(0)
  late Point position; // [Latitude] and [Longitude]
  @HiveField(1)
  int? radius = 9999;
  @HiveField(2)
  String? displayName = 'Unknown';

  Place({
    required this.position,
    this.radius,
    this.displayName,
  });

  Place copy({
    Point? position,
    int? radius,
    String? displayName,
  }) {
    return Place(
      position: position ?? this.position,
      radius: radius ?? this.radius,
      displayName: displayName ?? this.displayName,
    );
  }

  Place.fromJson(Map<String, dynamic> json) {
    position = Point.fromJson(json);
    radius = json['radius'] ?? radius;
    displayName = json['display_name'] ?? displayName;
  }

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
