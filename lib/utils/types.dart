import 'package:geolocator/geolocator.dart';

class LatLong {
  double latitude;
  double longitude;

  LatLong({required this.latitude, required this.longitude});

  bool setLatitude(double latitude) {
    if (latitude <= 90.0 || latitude >= -90.0) {
      this.latitude = latitude;
      return true;
    } else {
      return false;
    }
  }

  bool setLongitude(double longitude) {
    if (longitude <= 180.0 || longitude >= -180.0) {
      this.longitude = longitude;
      return true;
    } else {
      return false;
    }
  }

  bool isValid() {
    bool flag = true;
    flag &= (latitude <= 90.0 || latitude >= -90.0);
    flag &= (longitude <= 180.0 || longitude >= -180.0);
    return flag;
  }
}

class Place {
  LatLong position;
  String? displayName;

  Place({required this.position, this.displayName});
}

class Reminder {
  late String id;
  late String title;
  late LatLong position;
  String? displayName;
  int? radius = 1000;
  bool? withAlarm = true;
  String? notes;
  double? initialDistance;
  bool? isTracking = false;

  Reminder({
    required this.id,
    required this.title,
    required this.position,
    this.displayName,
    this.radius,
    this.withAlarm,
    this.notes,
    this.initialDistance,
    this.isTracking,
  });

  Reminder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    position = json['position'];
    displayName = json['displayName'];
    radius = json['radius'];
    withAlarm = json['withAlarm'];
    notes = json['notes'];
    initialDistance = json['initialDistance'];
    isTracking = json['isTracking'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'position': position,
      'displayName': displayName,
      'radius': radius,
      'withAlarm': withAlarm,
      'notes': notes,
      'initialDistance': initialDistance,
      'isTracking': isTracking,
    };
  }

  double getRemainderDistance(LatLong current) {
    double inMeters = Geolocator.distanceBetween(current.latitude,
        current.longitude, position.latitude, position.longitude);
    return inMeters;
  }

  double getBearing(LatLong current) {
    double inDegrees = Geolocator.bearingBetween(current.latitude,
        current.longitude, position.latitude, position.longitude);
    return inDegrees;
  }

  double getTraveledDistance(LatLong current) {
    double remainder = getRemainderDistance(current);
    if (initialDistance == null || initialDistance! < remainder) {
      initialDistance = remainder;
    }
    return (initialDistance! - remainder);
  }

  double? getTraveledDistancePercent(LatLong current) {
    double traveled = getTraveledDistance(current);
    if (initialDistance! == 0.0) {
      return 1;
    }
    return (traveled / initialDistance!);
  }
}
