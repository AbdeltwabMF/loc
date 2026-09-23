import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class AppDiagnostics {
  AppDiagnostics._();

  static const _headers = <String, String>{
    'Accept': 'application/json',
    'User-Agent': 'Loc Android/1.0.0 (+https://loc.abdeltwab.xyz)',
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
      _appVersion(),
      _locationServiceStatus(),
      _locationPermissionStatus(),
      _networkStatus(Uri.parse('https://tile.openstreetmap.org/0/0/0.png')),
      _networkStatus(
        Uri.https('nominatim.openstreetmap.org', '/status', {'format': 'json'}),
      ),
    ]);
    final [appVersion, locationEnabled, permission, tiles, search] = results;
    final events = _events.isEmpty
        ? 'None recorded this session'
        : _events.join('\n');

    return '''Loc diagnostics
Generated: ${DateTime.now().toUtc().toIso8601String()}
App: $appVersion
Platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}
Location service: $locationEnabled
Location permission: $permission
Reminder tracking: ${isTracking ? 'active' : 'inactive'}
OpenStreetMap tiles: $tiles
Nominatim search: $search

Recent issues (no locations, searches, or reminder content):
$events''';
  }

  static Future<String> _appVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version} (${info.buildNumber})';
    } on Object catch (error) {
      record('diagnostics.app-version', error);
      return 'unknown';
    }
  }

  static Future<String> _locationServiceStatus() async {
    try {
      return await Geolocator.isLocationServiceEnabled() ? 'on' : 'off';
    } on Object catch (error) {
      record('diagnostics.location-service', error);
      return 'check failed (${error.runtimeType})';
    }
  }

  static Future<String> _locationPermissionStatus() async {
    try {
      return (await Geolocator.checkPermission()).name;
    } on Object catch (error) {
      record('diagnostics.location-permission', error);
      return 'check failed (${error.runtimeType})';
    }
  }

  static Future<String> _networkStatus(Uri uri) async {
    final client = http.Client();
    try {
      final response = await client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 400
          ? 'reachable (${response.statusCode})'
          : 'server returned ${response.statusCode}';
    } on TimeoutException catch (error) {
      record('diagnostics.${uri.host}', error);
      return 'timed out (check VPN or firewall)';
    } on Object catch (error) {
      record('diagnostics.${uri.host}', error);
      return 'unreachable (${error.runtimeType})';
    } finally {
      client.close();
    }
  }
}
