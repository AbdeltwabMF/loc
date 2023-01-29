import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;

class AppStates extends ChangeNotifier {
  TextEditingController destLatitudeController =
      TextEditingController(text: '');
  TextEditingController destLongitudeController =
      TextEditingController(text: '');
  TextEditingController radiusController = TextEditingController(text: '100');

  double? currLatitude;
  double? currLongitude;

  bool isListening = false;
  double distance = -1.0;
  late StreamSubscription<geo.Position> positionStream;

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
    flag &= destLatitudeController.text != '';
    flag &= destLongitudeController.text != '';
    flag &= radiusController.text != '';

    return flag;
  }

  bool isDistanceValid() {
    return distance >= 0.0;
  }

  void setDistance(double distance) {
    this.distance = distance;
    notifyListeners();
  }
}
