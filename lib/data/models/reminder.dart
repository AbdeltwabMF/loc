import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:loc/data/models/place.dart';

class Reminder {
  late String id;
  late String title;
  late Place place;
  late double initialDistance;
  bool? isTracking = true;
  String? notes = '';

  Reminder({
    required this.id,
    required this.title,
    required this.place,
    required this.initialDistance,
    this.isTracking,
    this.notes,
  });

  Reminder.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    title = json['title'] as String;
    place = json['place'] as Place;
    initialDistance = json['initialDistance'] as double;
    isTracking = json['isTracking'] as bool;
    notes = json['notes'] as String;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'place': place,
      'initialDistance': initialDistance,
      'isTracking': isTracking,
      'notes': notes,
    };
  }

  double getRemainderDistance(LatLng current) {
    double inMeters = Geolocator.distanceBetween(current.latitude,
        current.longitude, place.position.latitude, place.position.longitude);
    return inMeters;
  }

  double getBearing(LatLng current) {
    double inDegrees = Geolocator.bearingBetween(current.latitude,
        current.longitude, place.position.latitude, place.position.longitude);
    return inDegrees;
  }

  double getTraveledDistance(LatLng current) {
    double remainder = getRemainderDistance(current);
    if (initialDistance < remainder) initialDistance = remainder;

    return (initialDistance - remainder);
  }

  double? getTraveledDistancePercent(LatLng current) {
    double traveled = getTraveledDistance(current);
    if (initialDistance == 0.0) return 1;
    return (traveled / initialDistance);
  }
}
