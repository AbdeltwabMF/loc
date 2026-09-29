import 'package:flutter_compass/flutter_compass.dart';

class CompassService {
  const CompassService();

  Stream<double?> get updates =>
      FlutterCompass.events?.map((event) => event.heading) ??
      Stream<double?>.value(null);

  static double directionTo(double bearing, double heading) =>
      (bearing - heading + 360) % 360;

  static bool isAligned(double direction, {double tolerance = 5}) {
    final normalized = (direction + 360) % 360;
    return normalized <= tolerance || normalized >= 360 - tolerance;
  }
}
