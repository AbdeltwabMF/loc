import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/models/point.dart';
import 'package:loc/place_presentation.dart';

void main() {
  test('uses the direction of the first strong address character', () {
    expect(_place('Cairo, مصر').displayLabelDirection, TextDirection.ltr);
    expect(_place('القاهرة, Cairo').displayLabelDirection, TextDirection.rtl);
    expect(_place('Москва, القاهرة').displayLabelDirection, TextDirection.ltr);
    expect(_place('Αθήνα, ירושלים').displayLabelDirection, TextDirection.ltr);
  });

  test('provides consistent place title, subtitle, and coordinates', () {
    final place = _place('Cairo, Egypt');

    expect(place.displayLabel, 'Cairo, Egypt');
    expect(place.displayTitle, 'Cairo');
    expect(place.displaySubtitle, 'Egypt');
    expect(place.coordinateLabel, '30.04440, 31.23570');
  });

  test('falls back to the dropped-pin label and left-to-right coordinates', () {
    final place = _place('  ');

    expect(place.displayLabel, Place.droppedPinLabel);
    expect(place.displayTitle, Place.droppedPinLabel);
    expect(place.displaySubtitle, '30.04440, 31.23570');
    expect(place.displaySubtitleDirection, TextDirection.ltr);
  });
}

Place _place(String? name) => Place(
  position: Point(latitude: 30.0444, longitude: 31.2357),
  displayName: name,
);
