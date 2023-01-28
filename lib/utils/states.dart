import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;

class AppStates extends ChangeNotifier {
  TextEditingController destLatitudeText = TextEditingController(text: '');
  TextEditingController destLongitudeText = TextEditingController(text: '');
  TextEditingController radiusText = TextEditingController(text: '100');

  double? currLatitude;
  double? currLongitude;

  late StreamSubscription<geo.Position> positionStream;

  bool isListening = false;

  void setLatitude(String latitude) {
    destLatitudeText.text = latitude;
    notifyListeners();
  }

  void setLongitude(String longitude) {
    destLongitudeText.text = longitude;
    notifyListeners();
  }

  void setRadius(String radius) {
    radiusText.text = radius;
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

  bool isLocValid() {
    return currLatitude != null && currLongitude != null;
  }
}
