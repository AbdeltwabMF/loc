import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:loc/app/app_metadata.dart';

class AppDiagnostics {
  AppDiagnostics._();

  static Map<String, String> get _headers => {
    'Accept': 'application/json',
    'User-Agent': AppMetadata.current.androidUserAgent,
  };
  static final List<String> _events = [];

  static void record(String area, Object error) {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final category = switch (error) {
      TimeoutException() => 'timeout',
      SocketException() => 'network',
      http.ClientException() => 'network',
      _ => error.runtimeType.toString(),
    };
    _events.add('$timestamp | $area | $category');
    if (_events.length > 20) _events.removeAt(0);
  }

  static String connectivityMessage() =>
      'Could not reach OpenStreetMap. Check your internet connection and '
      'allow Loc through any VPN, firewall, or data-saving app.';

  static Future<String> createReport({required bool isTracking}) async {
    final results = await Future.wait([
      _locationServiceStatus(),
      _locationPermissionStatus(),
      _networkStatus(Uri.parse('https://tile.openstreetmap.org/0/0/0.png')),
      _networkStatus(
        Uri.https('nominatim.openstreetmap.org', '/status', {'format': 'json'}),
      ),
    ]);
    final [locationEnabled, permission, tiles, search] = results;
    final events = _events.isEmpty
        ? 'None recorded this session'
        : _events.join('\n');

    return '''Loc diagnostics
Generated: ${DateTime.now().toUtc().toIso8601String()}
App: ${AppMetadata.current.displayVersion}
Platform: ${_platformLabel()} ${Platform.operatingSystemVersion}
Location services: $locationEnabled
Location permission: $permission
Reminder tracking: ${isTracking ? 'Active' : 'Inactive'}
Map tiles: $tiles
Search service: $search

Recent issues
No location, search, or reminder content is included.
$events''';
  }

  static Future<String> _locationServiceStatus() async {
    try {
      return await Geolocator.isLocationServiceEnabled() ? 'On' : 'Off';
    } on Object catch (error) {
      record('diagnostics.location-service', error);
      return 'Check failed (${error.runtimeType})';
    }
  }

  static Future<String> _locationPermissionStatus() async {
    try {
      return _permissionLabel(await Geolocator.checkPermission());
    } on Object catch (error) {
      record('diagnostics.location-permission', error);
      return 'Check failed (${error.runtimeType})';
    }
  }

  static Future<String> _networkStatus(Uri uri) async {
    final client = http.Client();
    try {
      final response = await client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 400
          ? 'Available (${response.statusCode})'
          : 'Server returned ${response.statusCode}';
    } on TimeoutException catch (error) {
      record('diagnostics.${uri.host}', error);
      return 'Timed out (check VPN or firewall)';
    } on Object catch (error) {
      record('diagnostics.${uri.host}', error);
      return 'Unavailable (${error.runtimeType})';
    } finally {
      client.close();
    }
  }

  static String _permissionLabel(LocationPermission permission) =>
      switch (permission) {
        LocationPermission.always => 'Always',
        LocationPermission.whileInUse => 'While in use',
        LocationPermission.denied => 'Denied',
        LocationPermission.deniedForever => 'Denied permanently',
        LocationPermission.unableToDetermine => 'Unable to determine',
      };

  static String _platformLabel() {
    final platform = Platform.operatingSystem;
    return '${platform[0].toUpperCase()}${platform.substring(1)}';
  }
}
