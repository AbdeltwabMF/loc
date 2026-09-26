import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:loc/data/models/point.dart';

class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

enum LocationAccessStatus {
  ready,
  serviceDisabled,
  permissionDenied,
  settingsRequired,
}

class LocationService {
  Stream<Point> get updates => _positionUpdates();

  Future<LocationAccessStatus> accessStatus({bool background = true}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccessStatus.serviceDisabled;
    }
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return LocationAccessStatus.permissionDenied;
    }
    if (permission == LocationPermission.deniedForever ||
        (background && permission != LocationPermission.always)) {
      return LocationAccessStatus.settingsRequired;
    }
    return LocationAccessStatus.ready;
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<void> ensurePermission({bool background = false}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
        'Turn on device location to track reminders.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location access is blocked. Enable it in Android settings.',
      );
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException('Location access was not granted.');
    }
    if (background && permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }
    if (background && permission != LocationPermission.always) {
      throw const LocationException(
        'Allow location all the time so reminders work while the screen is off.',
      );
    }
  }

  Future<Point> current() async {
    await ensurePermission();
    final position = await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      ),
    );
    return Point(latitude: position.latitude, longitude: position.longitude);
  }

  Stream<Point> _positionUpdates() =>
      Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          forceLocationManager: true,
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          intervalDuration: const Duration(seconds: 3),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: 'Loc is watching your route',
            notificationText: 'Active arrival reminders are being checked.',
            notificationChannelName: 'Arrival tracking',
            enableWakeLock: true,
            setOngoing: true,
          ),
        ),
      ).map(
        (position) =>
            Point(latitude: position.latitude, longitude: position.longitude),
      );
}
