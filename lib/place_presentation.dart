import 'package:flutter/widgets.dart';
import 'package:loc/data/models/place.dart';

final _strongCharacter = RegExp(
  r'[A-Za-z\u00C0-\u02AF\u0370-\u052F\u0590-\u08FF\uFB1D-\uFDFF\uFE70-\uFEFF]',
);
final _rtlCharacter = RegExp(r'[\u0590-\u08FF\uFB1D-\uFDFF\uFE70-\uFEFF]');

extension PlacePresentation on Place {
  String get displayLabel {
    final name = displayName?.trim();
    return name == null || name.isEmpty ? Place.droppedPinLabel : name;
  }

  String get displayTitle => displayLabel.split(',').first.trim();

  String get displaySubtitle {
    final name = displayName?.trim();
    if (name != null && name.contains(',')) {
      final subtitle = name.substring(name.indexOf(',') + 1).trim();
      if (subtitle.isNotEmpty) return subtitle;
    }
    return coordinateLabel;
  }

  String get coordinateLabel =>
      '${position.latitude.toStringAsFixed(5)}, '
      '${position.longitude.toStringAsFixed(5)}';

  TextDirection get displayLabelDirection => _textDirectionFor(displayLabel);

  TextDirection get displaySubtitleDirection =>
      _textDirectionFor(displaySubtitle);
}

TextDirection _textDirectionFor(String text) {
  final firstStrongCharacter = _strongCharacter.firstMatch(text)?.group(0);
  return firstStrongCharacter != null &&
          _rtlCharacter.hasMatch(firstStrongCharacter)
      ? TextDirection.rtl
      : TextDirection.ltr;
}
