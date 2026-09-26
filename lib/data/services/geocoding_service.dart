import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loc/app/app_metadata.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';

class GeocodingException implements Exception {
  const GeocodingException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GeocodingService {
  GeocodingService({http.Client? client, AppMetadata? appMetadata})
    : _client = client ?? http.Client(),
      _appMetadata = appMetadata ?? AppMetadata.current;

  static const _host = 'nominatim.openstreetmap.org';
  static const _invalidResponseMessage =
      'OpenStreetMap returned an invalid response. Try again later.';
  static const _connectivityMessage =
      'Could not reach OpenStreetMap. Check your internet connection and '
      'allow Loc through any VPN, firewall, or data-saving app.';

  final http.Client _client;
  final AppMetadata _appMetadata;

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'User-Agent': _appMetadata.androidUserAgent,
  };

  Future<Place> reverse(Point point) async {
    final uri = Uri.https(_host, '/reverse', {
      'format': 'jsonv2',
      'lat': point.latitude.toString(),
      'lon': point.longitude.toString(),
      'zoom': '16',
      'addressdetails': '1',
      'accept-language': 'en',
    });
    final json = await _get(uri);
    if (json is! Map<String, dynamic> ||
        json['lat'] is! String ||
        json['lon'] is! String ||
        (json['radius'] != null && json['radius'] is! int) ||
        (json['display_name'] != null && json['display_name'] is! String)) {
      throw const GeocodingException(_invalidResponseMessage);
    }
    try {
      return Place.fromJson(json);
    } on FormatException {
      throw const GeocodingException(_invalidResponseMessage);
    }
  }

  Future<Object?> _get(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw GeocodingException(
          'Map service returned ${response.statusCode}. Try again later.',
        );
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on GeocodingException {
      rethrow;
    } on TimeoutException {
      throw const GeocodingException(_connectivityMessage);
    } on http.ClientException {
      throw const GeocodingException(_connectivityMessage);
    } on FormatException {
      throw const GeocodingException(_invalidResponseMessage);
    }
  }

  void dispose() => _client.close();
}
