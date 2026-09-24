import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:loc/data/services/geo_uri_service.dart';

void main() {
  group('parseGeoUri', () {
    test('parses coordinates from the URI path', () {
      final place = parseGeoUri('geo:37.7749,-122.4194?z=14');

      expect(place, isNotNull);
      expect(place!.position.latitude, 37.7749);
      expect(place.position.longitude, -122.4194);
      expect(place.displayName, isNull);
    });

    test('prefers query coordinates and imports their label', () {
      final place = parseGeoUri(
        'geo:0,0?q=37.7749%2C-122.4194%28San%20Francisco%29',
      );

      expect(place, isNotNull);
      expect(place!.position.latitude, 37.7749);
      expect(place.position.longitude, -122.4194);
      expect(place.displayName, 'San Francisco');
    });

    test('falls back to path coordinates for a text search query', () {
      final place = parseGeoUri('geo:48.8584,2.2945?q=Eiffel+Tower');

      expect(place, isNotNull);
      expect(place!.position.latitude, 48.8584);
      expect(place.position.longitude, 2.2945);
      expect(place.displayName, 'Eiffel Tower');
    });

    test('imports a label attached to path coordinates', () {
      final place = parseGeoUri('geo:30.0275,31.2086(Cairo%20University)');

      expect(place, isNotNull);
      expect(place!.position.latitude, 30.0275);
      expect(place.position.longitude, 31.2086);
      expect(place.displayName, 'Cairo University');
    });

    test('rejects address-only and out-of-range locations', () {
      expect(parseGeoUri('geo:0,0?q=1600+Amphitheatre+Parkway'), isNull);
      expect(parseGeoUri('geo:91,0'), isNull);
      expect(parseGeoUri('https://example.com/37.7,-122.4'), isNull);
    });
  });

  group('parseSharedLocation', () {
    test('parses Google Maps query coordinates and shared label', () {
      final place = parseSharedLocationText(
        'Cairo University\nhttps://www.google.com/maps/search/?api=1&query=30.0275%2C31.2086',
      );

      expect(place, isNotNull);
      expect(place!.position.latitude, 30.0275);
      expect(place.position.longitude, 31.2086);
      expect(place.displayName, 'Cairo University');
    });

    test('parses coordinates embedded in a Google Maps place URL', () {
      final place = parseSharedLocationText(
        'https://www.google.com/maps/place/Cairo+University/@30.0275,31.2086,16z',
      );

      expect(place, isNotNull);
      expect(place!.position.latitude, 30.0275);
      expect(place.position.longitude, 31.2086);
      expect(place.displayName, 'Cairo University');
    });

    test('parses coordinates embedded in Google Maps data', () {
      final place = parseSharedLocationText(
        'https://www.google.com/maps/place/Test/data=!3m1!4b1!4m6!3d30.0275!4d31.2086',
      );

      expect(place, isNotNull);
      expect(place!.position.latitude, 30.0275);
      expect(place.position.longitude, 31.2086);
    });

    test('resolves a shortened Google Maps URL', () async {
      final client = MockClient(
        (_) async => http.Response(
          '',
          302,
          headers: {
            'location':
                'https://www.google.com/maps/place/Cairo+University/@30.0275,31.2086,16z',
          },
        ),
      );

      final place = await parseSharedLocation(
        'Cairo University\nhttps://maps.app.goo.gl/example',
        client,
      );

      expect(place, isNotNull);
      expect(place!.position.latitude, 30.0275);
      expect(place.position.longitude, 31.2086);
      expect(place.displayName, 'Cairo University');
    });

    test('resolves a Google Maps place ID without URL coordinates', () async {
      var requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        if (requestCount == 1) {
          return http.Response(
            '',
            302,
            headers: {
              'location':
                  'https://www.google.com/maps/place/Al+Wayli/data=!4m2!3m1!1s0x14581560192b32cd:0x5e8a42b754cac3f0!18m1!1e1',
            },
          );
        }
        expect(request.url.host, 'maps.google.com');
        expect(request.url.queryParameters['cid'], '6812330741520319472');
        expect(request.url.queryParameters['output'], 'embed');
        return http.Response(
          '[[[13806.71399385509,31.2867621,30.1033898],[0,0,0]]]',
          200,
        );
      });

      final place = await parseSharedLocation(
        'https://maps.app.goo.gl/F3MwnTKAfmPu7n277',
        client,
      );

      expect(place, isNotNull);
      expect(place!.position.latitude, 30.1033898);
      expect(place.position.longitude, 31.2867621);
      expect(place.displayName, 'Al Wayli');
      expect(requestCount, 2);
    });

    test('rejects unrelated links and text', () {
      expect(
        parseSharedLocationText('Meet me here: https://example.com/place'),
        isNull,
      );
    });
  });
}
