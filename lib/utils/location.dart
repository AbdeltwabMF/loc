import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:loc/utils/states.dart';
import 'package:provider/provider.dart';

Future<geo.Position> getCurrentLocation() async {
  bool isServiceEnabled = await geo.Geolocator.isLocationServiceEnabled();
  if (isServiceEnabled == false) {
    return Future.error('Location services are disabled.');
  }

  geo.LocationPermission permission = await geo.Geolocator.checkPermission();
  if (permission == geo.LocationPermission.denied) {
    permission = await geo.Geolocator.requestPermission();
  }

  if (permission == geo.LocationPermission.denied) {
    return Future.error('Location permission is denied');
  }

  if (permission == geo.LocationPermission.deniedForever) {
    return Future.error('Location permission is permanently denied');
  }

  return await geo.Geolocator.getCurrentPosition();
}

void listenToLocationUpdate(BuildContext context) {
  final provider = Provider.of<AppStates>(context, listen: false);

  geo.LocationSettings settings = const geo.LocationSettings(
    accuracy: geo.LocationAccuracy.high,
    distanceFilter: 50,
  );

  final subscription =
      geo.Geolocator.getPositionStream(locationSettings: settings)
          .listen((position) {
    provider.setCurrLatitude(position.latitude);
    provider.setCurrLongitude(position.longitude);

    if (calcDistance(context) <= double.parse(provider.radiusText.text)) {
      FlutterRingtonePlayer.playAlarm(
        looping: true,
        volume: 0.1,
        asAlarm: true,
      );
    }
  });

  provider.setPositionStream(subscription);
}

void cancelLocationUpdate(BuildContext context) {
  final provider = Provider.of<AppStates>(context, listen: false);
  provider.positionStream.cancel();
  provider.setListening(false);
  provider.setCurrLatitude(null);
  provider.setCurrLongitude(null);

  FlutterRingtonePlayer.stop();
}

double calcDistance(BuildContext context) {
  final provider = Provider.of<AppStates>(context, listen: false);
  if (provider.isLocValid() == false) return 0;

  final currentLatitude = provider.currLatitude!;
  final currentLongitude = provider.currLongitude!;
  final destLatitude = double.parse(provider.destLatitudeText.text);
  final destLongitude = double.parse(provider.destLongitudeText.text);

  final inMeters = geo.Geolocator.distanceBetween(
      destLatitude, destLongitude, currentLatitude, currentLongitude);

  return inMeters;
}

double toKiloMeter(double distanceInMeters) {
  if (distanceInMeters <= 1000) {
    return distanceInMeters;
  }
  distanceInMeters /= 1000;

  return double.parse(distanceInMeters.toStringAsPrecision(3));
}
