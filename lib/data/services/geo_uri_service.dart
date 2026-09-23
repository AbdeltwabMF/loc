import 'package:flutter/services.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';

class GeoUriService {
  static const _channel = EventChannel('xyz.abdeltwab.loc/geo_intents');

  static Stream<Place> get places => _channel
      .receiveBroadcastStream()
      .where((value) => value is String)
      .map((value) => parseGeoUri(value as String))
      .where((place) => place != null)
      .cast<Place>();
}

Place? parseGeoUri(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null || uri.scheme.toLowerCase() != 'geo') return null;

  final queryCoordinates = _parseCoordinates(uri.queryParameters['q']);
  final pathCoordinates = _parseCoordinates(uri.path);
  if (uri.queryParameters.containsKey('q') &&
      queryCoordinates == null &&
      pathCoordinates?.latitude == 0 &&
      pathCoordinates?.longitude == 0) {
    return null;
  }
  final coordinates = queryCoordinates ?? pathCoordinates;
  if (coordinates == null) return null;

  return Place(
    position: Point(
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
    ),
    displayName: queryCoordinates?.label,
  );
}

_GeoCoordinates? _parseCoordinates(String? value) {
  if (value == null) return null;
  final match = RegExp(
    r'^\s*([+-]?(?:\d+(?:\.\d*)?|\.\d+))\s*,\s*'
    r'([+-]?(?:\d+(?:\.\d*)?|\.\d+))'
    r'(?:\s*\((.*)\))?\s*$',
  ).firstMatch(value);
  if (match == null) return null;

  final latitude = double.tryParse(match.group(1)!);
  final longitude = double.tryParse(match.group(2)!);
  if (latitude == null ||
      longitude == null ||
      !latitude.isFinite ||
      !longitude.isFinite ||
      latitude < -90 ||
      latitude > 90 ||
      longitude < -180 ||
      longitude > 180) {
    return null;
  }

  final rawLabel = match.group(3)?.trim();
  return _GeoCoordinates(
    latitude,
    longitude,
    rawLabel == null || rawLabel.isEmpty ? null : rawLabel,
  );
}

class _GeoCoordinates {
  const _GeoCoordinates(this.latitude, this.longitude, this.label);

  final double latitude;
  final double longitude;
  final String? label;
}
