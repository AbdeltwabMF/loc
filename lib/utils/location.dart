import 'package:geolocator/geolocator.dart' as geo;

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
