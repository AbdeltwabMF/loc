import 'package:flutter/material.dart';
import 'package:loc/utils/open_street_map_picker.dart';

class AppLocationPicker extends StatelessWidget {
  const AppLocationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OpenStreetMapSearchAndPick(
          center: LatLong(30.05336456509493, 31.230701671759462),
          onPicked: (pickedData) {
            Navigator.of(context).pop<PickedData>(pickedData);
          }),
    );
  }
}
