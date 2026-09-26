import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:loc/app/app_metadata.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/services/geocoding_service.dart';

const _appMetadata = AppMetadata(version: 'test', buildNumber: '1');

void main() {
  test(
    'reverse geocoding preserves coordinates and uses a practical radius',
    () async {
      late http.Request captured;
      final service = GeocodingService(
        appMetadata: _appMetadata,
        client: MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'lat': '51.5074',
              'lon': '-0.1278',
              'display_name': 'London, United Kingdom',
            }),
            200,
          );
        }),
      );

      final place = await service.reverse(
        Point(latitude: 51.5074, longitude: -0.1278),
      );

      expect(place.position, Point(latitude: 51.5074, longitude: -0.1278));
      expect(place.radius, 500);
      expect(captured.url.queryParameters['accept-language'], 'en');
      expect(captured.headers['User-Agent'], contains('Loc Android/test'));
      service.dispose();
    },
  );

  test('surfaces an actionable error for a failed response', () async {
    final service = GeocodingService(
      appMetadata: _appMetadata,
      client: MockClient((request) async => http.Response('Unavailable', 503)),
    );

    await expectLater(
      service.reverse(Point(latitude: 0, longitude: 0)),
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

  test('explains that network filters can block reverse geocoding', () async {
    final service = GeocodingService(
      appMetadata: _appMetadata,
      client: MockClient(
        (request) async => throw http.ClientException('blocked'),
      ),
    );

    await expectLater(
      service.reverse(Point(latitude: 0, longitude: 0)),
      throwsA(
        isA<GeocodingException>()
            .having((error) => error.message, 'message', contains('firewall'))
            .having((error) => error.message, 'message', contains('VPN')),
      ),
    );
    service.dispose();
  });

  test('surfaces an actionable error for an invalid response', () async {
    final service = GeocodingService(
      appMetadata: _appMetadata,
      client: MockClient((request) async => http.Response('not json', 200)),
    );

    await expectLater(
      service.reverse(Point(latitude: 0, longitude: 0)),
      throwsA(
        isA<GeocodingException>().having(
          (error) => error.message,
          'message',
          contains('invalid response'),
        ),
      ),
    );
    service.dispose();
  });

  for (final invalidResponse in <Object>[
    <Object>[],
    {'lat': 51.5, 'lon': '-0.1'},
    {'lat': '51.5', 'lon': <Object>[]},
    {'lat': '51.5', 'lon': '-0.1', 'display_name': <String, Object>{}},
  ]) {
    test(
      'rejects reverse response with invalid schema: $invalidResponse',
      () async {
        final service = GeocodingService(
          appMetadata: _appMetadata,
          client: MockClient(
            (request) async => http.Response(jsonEncode(invalidResponse), 200),
          ),
        );

        await expectLater(
          service.reverse(Point(latitude: 0, longitude: 0)),
          throwsA(
            isA<GeocodingException>().having(
              (error) => error.message,
              'message',
              contains('invalid response'),
            ),
          ),
        );
        service.dispose();
      },
    );
  }
}
