import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:loc/utils/location.dart';

class AppStates extends ChangeNotifier {
  TextEditingController destDisplayNameController = TextEditingController();
  TextEditingController destLatitudeController = TextEditingController();
  TextEditingController destLongitudeController = TextEditingController();
  TextEditingController radiusController = TextEditingController(text: '100');
  TextEditingController distanceController = TextEditingController(text: null);

  double? currLatitude;
  double? currLongitude;

  bool isListening = false;
  late StreamSubscription<geo.Position> positionStream;

  void setDestDisplayNameController(String displayName) {
    destDisplayNameController.value = destDisplayNameController.value.copyWith(
      text: displayName,
    );
    notifyListeners();
  }

  void setDestLatitudeController(double latitude) {
    int intVal = latitude.round();
    final latText =
        latitude - intVal > 0 ? latitude.toString() : intVal.toString();
    destLatitudeController.value = destLatitudeController.value.copyWith(
      text: latText,
    );
    notifyListeners();
  }

  void setDestLongitudeController(double longitude) {
    int intVal = longitude.round();
    final longText =
        longitude - intVal > 0 ? longitude.toString() : intVal.toString();
    destLongitudeController.value = destLongitudeController.value.copyWith(
      text: longText,
    );
    notifyListeners();
  }

  void setRadiusController(int radius) {
    radiusController.value = radiusController.value.copyWith(
      text: radius.toString(),
    );
    notifyListeners();
  }

  void setDistanceController(double? distance) {
    distanceController.value = distanceController.value.copyWith(
      text: distance?.round().toString(),
    );
    notifyListeners();
  }

  void setRadius(String radius) {
    radiusController.text = radius;
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

  void setPositionStream(StreamSubscription<geo.Position> positionStream) {
    this.positionStream = positionStream;
    notifyListeners();
  }

  void setListening(bool listen) {
    isListening = listen;
    notifyListeners();
  }

  bool isLocationValid() {
    bool flag = true;
    flag &= currLatitude != null;
    flag &= currLongitude != null;

    return flag;
  }

  bool isInputValid() {
    bool flag = true;
    flag &= radiusController.text != '';
    flag &= validateNumber(destLatitudeController.text, limit: 190) == null;
    flag &= validateNumber(destLongitudeController.text, limit: 100) == null;

    return flag;
  }

  bool isDistanceValid() {
    return distanceController.text != 'null';
  }
}
