import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/services/geocoding_service.dart';

void main() {
  test('search identifies the app and encodes query parameters', () async {
    late http.Request captured;
    final service = GeocodingService(
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode([
            {
              'lat': '30.0444',
              'lon': '31.2357',
              'display_name': 'Cairo, Egypt',
            },
          ]),
          200,
        );
      }),
    );

    final results = await service.search('Cairo central station');

    expect(captured.url.queryParameters['q'], 'Cairo central station');
    expect(captured.headers['User-Agent'], contains('Loc Android'));
    expect(results.single.displayName, 'Cairo, Egypt');
    service.dispose();
  });

  test(
    'reverse geocoding preserves coordinates and uses a practical radius',
    () async {
      final service = GeocodingService(
        client: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'lat': '51.5074',
              'lon': '-0.1278',
              'display_name': 'London, United Kingdom',
            }),
            200,
          ),
        ),
      );

      final place = await service.reverse(
        Point(latitude: 51.5074, longitude: -0.1278),
      );

      expect(place.position, Point(latitude: 51.5074, longitude: -0.1278));
      expect(place.radius, 500);
      service.dispose();
    },
  );

  test('surfaces an actionable error for a failed response', () async {
    final service = GeocodingService(
      client: MockClient((request) async => http.Response('Unavailable', 503)),
    );

    await expectLater(
      service.search('Central station'),
      throwsA(
        isA<GeocodingException>().having(
          (error) => error.message,
          'message',
          contains('503'),
        ),
      ),
    );
    service.dispose();
  });
}
