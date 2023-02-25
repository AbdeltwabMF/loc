import 'package:latlong2/latlong.dart';

class Place {
  late LatLng position; // [Latitude] and [Longitude]
  int? radius = 9999;
  String? displayName = 'Unknown';

  Place({
    required this.position,
    this.radius,
    this.displayName,
  });

  Place.fromJson(Map<String, dynamic> json) {
    position = LatLng(double.parse(json['lat']), double.parse(json['lon']));
    radius = json['radius'] ?? radius;
    displayName = json['display_name'] ?? displayName;
  }

  Map<String, dynamic> toJson() {
    return {
      'position': LatLng(position.latitude, position.longitude),
      'radius': radius,
      'display_name': displayName,
    };
  }
}
