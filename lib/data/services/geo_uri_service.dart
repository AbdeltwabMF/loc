import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';

class GeoUriService {
  static const _channel = EventChannel('xyz.abdeltwab.loc/geo_intents');
  static final _httpClient = http.Client();
  static final ValueNotifier<bool> isResolving = ValueNotifier(false);

  static final Stream<Place> places = _channel
      .receiveBroadcastStream()
      .where((value) => value is String)
      .asyncMap((value) async {
        isResolving.value = true;
        try {
          return await parseSharedLocation(value as String, _httpClient);
        } finally {
          isResolving.value = false;
        }
      })
      .where((place) => place != null)
      .cast<Place>()
      .asBroadcastStream();
}

Future<Place?> parseSharedLocation(String value, [http.Client? client]) async {
  final localPlace = parseSharedLocationText(value);
  if (localPlace != null) return localPlace;

  final googleUrls = _urlsIn(value).where(_isGoogleMapsUrl);
  final shortUrl = googleUrls.where(_isShortGoogleMapsUrl).firstOrNull;
  var resolvedUrl = googleUrls
      .where((url) => !_isShortGoogleMapsUrl(url))
      .firstOrNull;
  if (shortUrl == null && resolvedUrl == null) return null;

  final ownsClient = client == null;
  final requestClient = client ?? http.Client();
  try {
    if (shortUrl != null) {
      resolvedUrl = await _resolveShortGoogleMapsUrl(
        shortUrl,
        requestClient,
      ).timeout(const Duration(seconds: 10));
    }
    if (resolvedUrl == null) return null;

    final label = _labelFrom(value) ?? _labelFromPath(resolvedUrl);
    final redirectedPlace = _placeFromGoogleMapsUri(resolvedUrl, label: label);
    if (redirectedPlace != null) return redirectedPlace;
    return await _placeFromGoogleMapsCid(
      resolvedUrl,
      requestClient,
      label,
    ).timeout(const Duration(seconds: 10));
  } finally {
    if (ownsClient) requestClient.close();
  }
}

Future<Place?> _placeFromGoogleMapsCid(
  Uri uri,
  http.Client client,
  String? label,
) async {
  final cid = _cidFromGoogleMapsUri(uri);
  if (cid == null) return null;

  final response = await client.get(
    Uri.https('maps.google.com', '/maps', {'cid': cid, 'output': 'embed'}),
    headers: const {'User-Agent': 'Loc Android'},
  );
  if (response.statusCode < 200 || response.statusCode >= 300) return null;

  final number = r'[+-]?(?:\d+(?:\.\d*)?|\.\d+)';
  final match = RegExp(
    '\\[\\[\\[[^,\\]]+,($number),($number)\\]',
  ).firstMatch(response.body);
  if (match == null) return null;
  final coordinates = _parseCoordinates('${match[2]},${match[1]}');
  return coordinates == null ? null : _placeFromCoordinates(coordinates, label);
}

String? _cidFromGoogleMapsUri(Uri uri) {
  final match = RegExp(
    r'!1s0x[0-9a-f]+:0x([0-9a-f]+)',
    caseSensitive: false,
  ).firstMatch(uri.toString());
  if (match == null) return null;
  return BigInt.parse(match[1]!, radix: 16).toString();
}

Future<Uri?> _resolveShortGoogleMapsUrl(Uri url, http.Client client) async {
  var current = url;
  for (var redirectCount = 0; redirectCount < 5; redirectCount++) {
    final request = http.Request('GET', current)
      ..followRedirects = false
      ..headers['User-Agent'] = 'Loc Android';
    final response = await client.send(request);
    await response.stream.drain<void>();
    final location = response.headers['location'];
    if (response.statusCode < 300 ||
        response.statusCode >= 400 ||
        location == null) {
      return current == url ? null : current;
    }
    final next = current.resolve(location);
    if (!_isGoogleMapsUrl(next)) return null;
    current = next;
    if (!_isShortGoogleMapsUrl(current)) return current;
  }
  return null;
}

Place? parseSharedLocationText(String value) {
  final geoPlace = parseGeoUri(value.trim());
  if (geoPlace != null) return geoPlace;

  final label = _labelFrom(value);
  for (final url in _urlsIn(value)) {
    final place = _placeFromGoogleMapsUri(url, label: label);
    if (place != null) return place;
  }

  for (final line in value.split(RegExp(r'[\r\n]+'))) {
    final coordinates = _parseCoordinates(line.trim());
    if (coordinates != null) return _placeFromCoordinates(coordinates, label);
  }
  return null;
}

Place? parseGeoUri(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null || uri.scheme.toLowerCase() != 'geo') return null;

  final queryCoordinates = _parseCoordinates(uri.queryParameters['q']);
  final pathCoordinates = _parseCoordinates(uri.path, decodeLabel: true);
  if (uri.queryParameters.containsKey('q') &&
      queryCoordinates == null &&
      pathCoordinates?.latitude == 0 &&
      pathCoordinates?.longitude == 0) {
    return null;
  }
  final coordinates = queryCoordinates ?? pathCoordinates;
  if (coordinates == null) return null;

  final query = uri.queryParameters['q']?.trim();
  final queryLabel = queryCoordinates == null && query?.isNotEmpty == true
      ? query
      : null;
  final displayName = queryCoordinates != null
      ? queryCoordinates.label
      : queryLabel ?? pathCoordinates?.label;
  return _placeFromCoordinates(coordinates, displayName);
}

Place? _placeFromGoogleMapsUri(Uri uri, {String? label}) {
  if (!_isGoogleMapsUrl(uri) || _isShortGoogleMapsUrl(uri)) return null;

  for (final parameter in const ['q', 'query', 'destination', 'daddr']) {
    final coordinates = _parseCoordinates(uri.queryParameters[parameter]);
    if (coordinates != null) {
      return _placeFromCoordinates(coordinates, label ?? coordinates.label);
    }
  }

  final atMatch = RegExp(
    r'/@([+-]?(?:\d+(?:\.\d*)?|\.\d+)),([+-]?(?:\d+(?:\.\d*)?|\.\d+))',
  ).firstMatch(uri.path);
  if (atMatch != null) {
    final coordinates = _parseCoordinates('${atMatch[1]},${atMatch[2]}');
    if (coordinates != null) {
      return _placeFromCoordinates(coordinates, label ?? _labelFromPath(uri));
    }
  }

  final dataMatch = RegExp(
    r'!3d([+-]?(?:\d+(?:\.\d*)?|\.\d+))!4d([+-]?(?:\d+(?:\.\d*)?|\.\d+))',
  ).firstMatch(uri.toString());
  if (dataMatch == null) return null;
  final coordinates = _parseCoordinates('${dataMatch[1]},${dataMatch[2]}');
  return coordinates == null
      ? null
      : _placeFromCoordinates(coordinates, label ?? _labelFromPath(uri));
}

Place _placeFromCoordinates(_GeoCoordinates coordinates, String? label) =>
    Place(
      position: Point(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
      ),
      displayName: label == null || label.trim().isEmpty ? null : label.trim(),
    );

Iterable<Uri> _urlsIn(String value) sync* {
  for (final match in RegExp(r'https?://[^\s<>]+').allMatches(value)) {
    final raw = match.group(0)!.replaceFirst(RegExp(r'[),.;]+$'), '');
    final uri = Uri.tryParse(raw);
    if (uri != null) yield uri;
  }
}

bool _isGoogleMapsUrl(Uri uri) {
  final host = uri.host.toLowerCase();
  return host == 'maps.app.goo.gl' ||
      host == 'goo.gl' ||
      host == 'maps.google.com' ||
      host == 'www.google.com' ||
      host.endsWith('.google.com');
}

bool _isShortGoogleMapsUrl(Uri uri) {
  final host = uri.host.toLowerCase();
  return host == 'maps.app.goo.gl' ||
      (host == 'goo.gl' && uri.path.startsWith('/maps'));
}

String? _labelFrom(String value) {
  for (final line in value.split(RegExp(r'[\r\n]+'))) {
    final candidate = line.trim();
    if (candidate.isNotEmpty && !_urlsIn(candidate).iterator.moveNext()) {
      if (_parseCoordinates(candidate) == null) return candidate;
    }
  }
  return null;
}

String? _labelFromPath(Uri uri) {
  final segments = uri.pathSegments;
  final placeIndex = segments.indexOf('place');
  if (placeIndex == -1 || placeIndex + 1 >= segments.length) return null;
  return segments[placeIndex + 1].replaceAll('+', ' ').trim();
}

_GeoCoordinates? _parseCoordinates(String? value, {bool decodeLabel = false}) {
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

  final matchedLabel = match.group(3)?.trim();
  final rawLabel = decodeLabel ? _decodeLabel(matchedLabel) : matchedLabel;
  return _GeoCoordinates(
    latitude,
    longitude,
    rawLabel == null || rawLabel.isEmpty ? null : rawLabel,
  );
}

String? _decodeLabel(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return Uri.decodeComponent(value);
  } on FormatException {
    return value;
  }
}

class _GeoCoordinates {
  const _GeoCoordinates(this.latitude, this.longitude, this.label);

  final double latitude;
  final double longitude;
  final String? label;
}
