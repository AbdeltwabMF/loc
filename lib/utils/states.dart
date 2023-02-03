import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:loc/utils/location.dart';

class AppStates extends ChangeNotifier {
  TextEditingController destDisplayNameController = TextEditingController();
  TextEditingController destLatitudeController = TextEditingController();
  TextEditingController destLongitudeController = TextEditingController();
  TextEditingController currDisplayNameController = TextEditingController();
  TextEditingController radiusController = TextEditingController(text: '100');
  TextEditingController distanceController = TextEditingController(text: null);
  TextEditingController bearingController = TextEditingController(text: null);

  double? currLatitude;
  double? currLongitude;

  bool isListening = false;
  late StreamSubscription<geo.Position> positionStream;

  void setDestDisplayName(String displayName) {
    destDisplayNameController.value = destDisplayNameController.value.copyWith(
      text: displayName,
    );
    notifyListeners();
  }

  void setDestLatitude(String latitude) {
    destLatitudeController.value = destLatitudeController.value.copyWith(
      text: latitude,
    );
    notifyListeners();
  }

  void setDestLongitude(String longitude) {
    destLongitudeController.value = destLongitudeController.value.copyWith(
      text: longitude,
    );
    notifyListeners();
  }

  void setCurrDisplayName(String displayName) {
    currDisplayNameController.value = currDisplayNameController.value.copyWith(
      text: displayName,
    );
    notifyListeners();
  }

  void setCurrLatitude(double? latitude) {
    currLatitude = latitude;
    notifyListeners();
  }

  void setCurrLongitude(double? longitude) {
    currLongitude = longitude;
    notifyListeners();
  }

  void setRadius(String radius) {
    radiusController.value = radiusController.value.copyWith(
      text: radius,
    );
    notifyListeners();
  }

  void setDistance(double? distance) {
    distanceController.value = distanceController.value.copyWith(
      text: distance?.round().toString(),
    );
    notifyListeners();
  }

  void setBearing(double? bearing) {
    bearingController.value = bearingController.value.copyWith(
      text: bearing?.round().toString(),
    );
    notifyListeners();
  }

  void setPositionStream(StreamSubscription<geo.Position> positionStream) {
    this.positionStream = positionStream;
    notifyListeners();
  }

  void setListening(bool listen) {
    isListening = listen;
    notifyListeners();
  }

  bool isCurrentLocationValid() {
    bool flag = true;
    flag &= currLatitude != null;
    flag &= currLongitude != null;

    return flag;
  }

  bool isDestinationLocationValid() {
    bool flag = true;
    flag &= radiusController.text != '';
    flag &= validateNumber(destLatitudeController.text, limit: 90) == null;
    flag &= validateNumber(destLongitudeController.text, limit: 180) == null;

    return flag;
  }

  bool isDistanceValid() {
    return distanceController.text != '';
  }
}
