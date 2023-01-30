import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:loc/utils/states.dart';
import 'package:provider/provider.dart';

Future<bool> checkLocationPermission() async {
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

Future<geo.Position> getCurrentLocation() async {
  final result = await checkLocationPermission().then((value) async {
    return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);
  }).onError((error, stackTrace) {
    return Future.error(error!, stackTrace);
  });

  return result;
}

void listenLocationUpdate(BuildContext context) {
  final provider = Provider.of<AppStates>(context, listen: false);

  geo.LocationSettings settings = const geo.LocationSettings(
    accuracy: geo.LocationAccuracy.high,
    distanceFilter: 8,
  );

  final subscription =
      geo.Geolocator.getPositionStream(locationSettings: settings).listen(
          (position) {
            provider.setCurrLatitude(position.latitude);
            provider.setCurrLongitude(position.longitude);
            provider.setDistanceController(calcDistance(context));
            shouldPlaySound(context);
          },
          cancelOnError: true,
          onError: (error, stackTrace) {
            debugPrint(error.toString());
            debugPrint(stackTrace.toString());
          });

  provider.setPositionStream(subscription);
}

void cancelLocationUpdate(BuildContext context) {
  final provider = Provider.of<AppStates>(context, listen: false);
  provider.positionStream.cancel();
}

double calcDistance(BuildContext context) {
  final provider = Provider.of<AppStates>(context, listen: false);
  if (provider.isLocationValid() == false) return -1.0;
  if (provider.isInputValid() == false) return -1.0;

  final currentLatitude = provider.currLatitude!;
  final currentLongitude = provider.currLongitude!;
  final destLatitude = double.parse(provider.destLatitudeController.text);
  final destLongitude = double.parse(provider.destLongitudeController.text);

  final inMeters = geo.Geolocator.distanceBetween(
      destLatitude, destLongitude, currentLatitude, currentLongitude);

  return inMeters;
}

void shouldPlaySound(BuildContext context) {
  final provider = Provider.of<AppStates>(context, listen: false);
  if (provider.isListening == false ||
      provider.isInputValid() == false ||
      provider.isDistanceValid() == false) {
    FlutterRingtonePlayer.stop();
    return;
  }

  final distance = double.parse(provider.distanceController.text);
  if (distance <= double.parse(provider.radiusController.text)) {
    debugPrint(distance.toString());
    debugPrint(provider.radiusController.text);

    FlutterRingtonePlayer.playAlarm(
      looping: true,
      volume: 0.1,
      asAlarm: true,
    );
  } else {
    FlutterRingtonePlayer.stop();
  }
}

String? validateNumber(String? value,
    {String? message = 'Not a number', double limit = 1000000000.0}) {
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
