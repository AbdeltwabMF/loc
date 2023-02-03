import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:loc/screens/osm_map_view.dart';
import 'package:loc/utils/states.dart';
import 'package:provider/provider.dart';

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

  final subscription = geo.Geolocator.getPositionStream(
    distanceFilter: 16,
    forceAndroidLocationManager: true,
    intervalDuration: const Duration(seconds: 10),
  ).listen(
      (value) async {
        provider.setCurrLatitude(value.latitude);
        provider.setCurrLongitude(value.longitude);

        provider.setDistance(distanceAndBearing(context)?.first);
        provider.setBearing(distanceAndBearing(context)?.last);
        shouldPlaySound(context);

        LocationData locationData =
            LocationData(latitude: value.latitude, longitude: value.longitude);
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

bool isInRange(BuildContext context) {
  final provider = Provider.of<AppStates>(context, listen: false);

  if (provider.isDestinationLocationValid() == false ||
      provider.isDistanceValid() == false) {
    return false;
  }

  final distance = double.parse(provider.distanceController.text);
  if (distance <= double.parse(provider.radiusController.text)) {
    return true;
  } else {
    return false;
  }
}

bool shouldPlaySound(BuildContext context) {
  final provider = Provider.of<AppStates>(context, listen: false);
  if (provider.isListening == false) {
    FlutterRingtonePlayer.stop();
    return false;
  }

  if (isInRange(context) == true) {
    FlutterRingtonePlayer.playAlarm(
      looping: true,
      volume: 0.1,
      asAlarm: true,
    );
    return true;
  } else {
    FlutterRingtonePlayer.stop();
    return false;
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
      desiredAccuracy: geo.LocationAccuracy.best,
    );
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
