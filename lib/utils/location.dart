import 'package:geolocator/geolocator.dart' as geo;
import 'package:geolocator_apple/geolocator_apple.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:loc/screens/osm_map_view.dart';
import 'package:loc/utils/states.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

Future<bool> _checkPermissions() async {
  bool isServiceEnabled = await geo.Geolocator.isLocationServiceEnabled();
  if (isServiceEnabled == false) {
    return Future.error('Location services are disabled.');
  }

  geo.LocationPermission permission = await geo.Geolocator.checkPermission();
  if (permission == geo.LocationPermission.denied) {
    permission = await geo.Geolocator.requestPermission();
  }

  if (permission == geo.LocationPermission.denied) {
    return Future.error('Location services permission is denied');
  }

  if (permission == geo.LocationPermission.deniedForever) {
    return Future.error('Location services permission is permanently denied');
  }
  return true;
}

// APIs

void handlePositionUpdates(BuildContext context) {
  final provider = Provider.of<AppStates>(context, listen: false);

  late LocationSettings locationSettings;
  if (defaultTargetPlatform == TargetPlatform.android) {
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50,
      forceLocationManager: true,
      intervalDuration: const Duration(seconds: 10),
    );
  } else if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    locationSettings = AppleSettings(
      accuracy: LocationAccuracy.best,
      activityType: ActivityType.fitness,
      distanceFilter: 16,
      pauseLocationUpdatesAutomatically: true,
      showBackgroundLocationIndicator: false,
    );
  } else {
    locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 16,
    );
  }

  final subscription =
      geo.Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen(
              (value) async {
                provider.setCurrLatitude(value.latitude);
                provider.setCurrLongitude(value.longitude);

                provider.setDistance(distanceAndBearing(context)?.first);
                provider.setBearing(distanceAndBearing(context)?.last);
                shouldPlaySound(context);

                LocationData locationData = LocationData(
                    latitude: value.latitude, longitude: value.longitude);
                final decodedResponse = await osmReverse(locationData);
                provider.setCurrDisplayName(decodedResponse['display_name']);
              },
              cancelOnError: true,
              onError: (error, stackTrace) {
                debugPrint(error.toString());
                debugPrint(stackTrace.toString());
              });

  provider.setPositionStream(subscription);
}

void cancelPositionUpdates(BuildContext context) {
  final provider = Provider.of<AppStates>(context, listen: false);
  provider.positionStream.cancel();
}

void shouldPlaySound(BuildContext context) {
  final provider = Provider.of<AppStates>(context, listen: false);
  if (provider.isListening == false ||
      provider.isDestinationLocationValid() == false ||
      provider.isDistanceValid() == false) {
    FlutterRingtonePlayer.stop();
    return;
  }

  final distance = double.parse(provider.distanceController.text);
  if (distance <= double.parse(provider.radiusController.text)) {
    FlutterRingtonePlayer.playAlarm(
      looping: true,
      volume: 0.1,
      asAlarm: true,
    );
    debugPrint(distance.toString());
    debugPrint(provider.radiusController.text);
  } else {
    FlutterRingtonePlayer.stop();
  }
}

String? validateNumber(String? value,
    {String? message = 'Not a number', double limit = 1.0}) {
  if (value == null || value == '') {
    return message;
  } else {
    final validNumber = double.tryParse(value);
    if (validNumber == null || validNumber > limit || validNumber < -limit) {
      return message;
    }
  }
  return null;
}

Future<geo.Position> getCurrentLocation() async {
  final result = await _checkPermissions().then((value) async {
    return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.best);
  }).onError((error, stackTrace) {
    return Future.error(error!, stackTrace);
  });

  return result;
}

List<double?>? distanceAndBearing(BuildContext context) {
  final provider = Provider.of<AppStates>(context, listen: false);

  // Check for values you gonna compare
  if (provider.isCurrentLocationValid() == false) return null;
  if (provider.isDestinationLocationValid() == false) return null;

  final currentLatitude = provider.currLatitude!;
  final currentLongitude = provider.currLongitude!;
  final destLatitude = double.parse(provider.destLatitudeController.text);
  final destLongitude = double.parse(provider.destLongitudeController.text);

  final returnValue = <double?>[];
  double inMeters = geo.Geolocator.distanceBetween(
      currentLatitude, currentLongitude, destLatitude, destLongitude);

  returnValue.add(inMeters);
  inMeters = geo.Geolocator.bearingBetween(
      currentLatitude, currentLongitude, destLatitude, destLongitude);
  returnValue.add(inMeters);

  // First is distance
  // Second is bearing
  return returnValue;
}
