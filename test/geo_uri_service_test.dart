import 'package:flutter_test/flutter_test.dart';
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
    });

    test('rejects address-only and out-of-range locations', () {
      expect(parseGeoUri('geo:0,0?q=1600+Amphitheatre+Parkway'), isNull);
      expect(parseGeoUri('geo:91,0'), isNull);
      expect(parseGeoUri('https://example.com/37.7,-122.4'), isNull);
    });
  });
}
