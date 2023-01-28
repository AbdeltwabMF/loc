import 'package:flutter/material.dart';

class AppStates extends ChangeNotifier {
  TextEditingController latitudeText = TextEditingController();
  TextEditingController longitudeText = TextEditingController();
  TextEditingController radiusText = TextEditingController();

  void setLatitude(String latitude) {
    latitudeText.text = latitude;
    notifyListeners();
  }

  void setLongitude(String longitude) {
    longitudeText.text = longitude;
    notifyListeners();
  }

  void setRadius(String radius) {
    radiusText.text = radius;
    notifyListeners();
  }
}
