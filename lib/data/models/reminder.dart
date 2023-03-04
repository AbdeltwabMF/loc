import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:loc/data/models/place.dart';

class Reminder {
  late String id;
  late String title;
  late Place place;
  late double initialDistance;
  late bool isTracking;
  late bool isArrived;
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

  double remainderDistance(LatLng current) {
    double inMeters = Geolocator.distanceBetween(current.latitude,
        current.longitude, place.position.latitude, place.position.longitude);
    return inMeters;
  }

  double bearing(LatLng current) {
    double inDegrees = Geolocator.bearingBetween(current.latitude,
        current.longitude, place.position.latitude, place.position.longitude);
    return inDegrees;
  }

  double traveledDistance(LatLng current) {
    double remainder = remainderDistance(current);
    if (initialDistance < remainder) initialDistance = remainder;

    return (initialDistance - remainder);
  }

  double? traveledDistancePercent(LatLng current) {
    double traveled = traveledDistance(current);
    if (initialDistance == 0.0) return 1;
    return (traveled / initialDistance);
  }
}
