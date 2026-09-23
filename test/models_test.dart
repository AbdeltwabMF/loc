import 'package:flutter_test/flutter_test.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/data/models/reminder.dart';
import 'package:loc/data/services/compass_service.dart';

void main() {
  group('Place identity', () {
    test('uses coordinates rather than object identity', () {
      final first = Place(position: Point(latitude: 10, longitude: 20));
      final second = Place(
        position: Point(latitude: 10, longitude: 20),
        displayName: 'Different label',
      );

      expect(first, second);
      expect({first, second}, hasLength(1));
    });

    test('defaults to a practical arrival radius', () {
      final place = Place(position: Point(latitude: 10, longitude: 20));

      expect(place.radius, 500);
      expect(place.displayName, 'Dropped pin');
    });

    test('treats nearby coordinates as the same saved location', () {
      final first = Place(
        position: Point(latitude: 30.0444, longitude: 31.2357),
      );
      final nearby = Place(
        position: Point(latitude: 30.0445, longitude: 31.2357),
      );
      final distant = Place(
        position: Point(latitude: 30.0450, longitude: 31.2357),
      );

      expect(first.isSameLocation(nearby), isTrue);
      expect(first.isSameLocation(distant), isFalse);
    });
  });

  group('Reminder distance', () {
    test('reports zero progress before an initial location is known', () {
      final reminder = Reminder(
        id: 'id',
        title: 'Station',
        place: Place(position: Point(latitude: 10, longitude: 20)),
        initialDistance: 0,
        isTracking: true,
        isArrived: false,
      );

      expect(
        reminder.traveledDistancePercent(
          Point(latitude: 10.01, longitude: 20.01),
        ),
        0,
      );
    });

    test('clamps progress when moving farther from the destination', () {
      final reminder = Reminder(
        id: 'id',
        title: 'Station',
        place: Place(position: Point(latitude: 10, longitude: 20)),
        initialDistance: 100,
        isTracking: true,
        isArrived: false,
      );

      expect(
        reminder.traveledDistancePercent(Point(latitude: 11, longitude: 21)),
        0,
      );
    });

    test('supports brief, vibration, and alarm alert styles', () {
      final reminder = Reminder(
        id: 'id',
        title: 'Station',
        place: Place(position: Point(latitude: 10, longitude: 20)),
        initialDistance: 100,
        isTracking: true,
        isArrived: false,
      );

      expect(reminder.alertStyle, ReminderAlertStyle.brief);
      expect(
        reminder.copy(isVibration: true).alertStyle,
        ReminderAlertStyle.vibration,
      );
      expect(reminder.copy(isAlarm: true).alertStyle, ReminderAlertStyle.alarm);
    });

    test('detects arrival inside the configured radius', () {
      final reminder = Reminder(
        id: 'id',
        title: 'Station',
        place: Place(
          position: Point(latitude: 30.0444, longitude: 31.2357),
          radius: 100,
        ),
        initialDistance: 0,
        isTracking: true,
        isArrived: false,
      );

      expect(
        reminder.hasArrived(Point(latitude: 30.04442, longitude: 31.2357)),
        isTrue,
      );
      expect(
        reminder.hasArrived(Point(latitude: 30.046, longitude: 31.2357)),
        isFalse,
      );
    });

    test('detects crossing the arrival zone between location samples', () {
      final reminder = Reminder(
        id: 'id',
        title: 'Station',
        place: Place(
          position: Point(latitude: 30.0444, longitude: 31.2357),
          radius: 100,
        ),
        initialDistance: 0,
        isTracking: true,
        isArrived: false,
      );

      expect(
        reminder.pathIntersectsArrivalZone(
          Point(latitude: 30.0444, longitude: 31.2345),
          Point(latitude: 30.0444, longitude: 31.2369),
        ),
        isTrue,
      );
      expect(
        reminder.pathIntersectsArrivalZone(
          Point(latitude: 30.046, longitude: 31.2345),
          Point(latitude: 30.046, longitude: 31.2369),
        ),
        isFalse,
      );
    });

    test('reports compass bearings clockwise from north', () {
      Reminder reminderAt(double latitude, double longitude) => Reminder(
        id: 'id',
        title: 'Destination',
        place: Place(
          position: Point(latitude: latitude, longitude: longitude),
        ),
        initialDistance: 0,
        isTracking: true,
        isArrived: false,
      );

      final origin = Point(latitude: 0, longitude: 0);

      expect(reminderAt(1, 0).bearing(origin), closeTo(0, 0.01));
      expect(reminderAt(0, 1).bearing(origin), closeTo(90, 0.01));
      expect(reminderAt(-1, 0).bearing(origin), closeTo(180, 0.01));
      expect(reminderAt(0, -1).bearing(origin), closeTo(270, 0.01));
    });

    test('points toward the destination relative to device heading', () {
      final reminder = Reminder(
        id: 'id',
        title: 'Destination',
        place: Place(position: Point(latitude: 0, longitude: 1)),
        initialDistance: 0,
        isTracking: true,
        isArrived: false,
      );
      final origin = Point(latitude: 0, longitude: 0);

      final bearing = reminder.bearing(origin);
      expect(CompassService.directionTo(bearing, 90), closeTo(0, 0.01));
      expect(CompassService.directionTo(bearing, 0), closeTo(90, 0.01));
      expect(CompassService.directionTo(bearing, 180), closeTo(270, 0.01));
    });
  });
}
