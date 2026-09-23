import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loc/text_direction.dart';

void main() {
  test('uses the direction of the first strong address character', () {
    expect(textDirectionFor('Cairo, مصر'), TextDirection.ltr);
    expect(textDirectionFor('القاهرة, Cairo'), TextDirection.rtl);
  });

  test('keeps coordinates left to right', () {
    expect(textDirectionFor('30.0444, 31.2357'), TextDirection.ltr);
  });
}
