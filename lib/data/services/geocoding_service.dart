import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/services/app_diagnostics.dart';

class GeocodingException implements Exception {
  const GeocodingException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GeocodingService {
  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  static const _host = 'nominatim.openstreetmap.org';
  static const _headers = <String, String>{
    'Accept': 'application/json',
    'User-Agent': 'Loc Android/0.7 (https://loc.abdeltwab.xyz)',
  };

  final http.Client _client;

  Future<Place> reverse(Point point) async {
    final uri = Uri.https(_host, '/reverse', {
      'format': 'jsonv2',
      'lat': point.latitude.toString(),
      'lon': point.longitude.toString(),
      'zoom': '16',
      'addressdetails': '1',
    });
    final json = await _get(uri);
    return Place.fromJson(json as Map<String, dynamic>);
  }

  Future<List<Place>> search(String query) async {
    final value = query.trim();
    if (value.length < 3) return const [];
    final uri = Uri.https(_host, '/search', {
      'format': 'jsonv2',
      'q': value,
      'addressdetails': '1',
      'limit': '6',
    });
    final json = await _get(uri) as List<dynamic>;
    return json
        .cast<Map<String, dynamic>>()
        .map(Place.fromJson)
        .toList(growable: false);
  }

  Future<Object?> _get(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        AppDiagnostics.record(
          'geocoding.http-${response.statusCode}',
          GeocodingException('HTTP ${response.statusCode}'),
        );
        throw GeocodingException(
          'Map service returned ${response.statusCode}. Try again later.',
        );
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on GeocodingException {
      rethrow;
    } on TimeoutException catch (error) {
      AppDiagnostics.record('geocoding.${uri.pathSegments.first}', error);
      throw GeocodingException(AppDiagnostics.connectivityMessage());
    } on http.ClientException catch (error) {
      AppDiagnostics.record('geocoding.${uri.pathSegments.first}', error);
      throw GeocodingException(AppDiagnostics.connectivityMessage());
    } on FormatException catch (error) {
      AppDiagnostics.record('geocoding.response', error);
      throw const GeocodingException(
        'OpenStreetMap returned an invalid response. Try again later.',
      );
    }
  }

  void dispose() => _client.close();
}
