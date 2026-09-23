import 'package:flutter/widgets.dart';

final _strongCharacter = RegExp(
  r'[A-Za-z\u00C0-\u02AF\u0590-\u08FF\uFB1D-\uFDFF\uFE70-\uFEFF]',
);
final _rtlCharacter = RegExp(r'[\u0590-\u08FF\uFB1D-\uFDFF\uFE70-\uFEFF]');

TextDirection textDirectionFor(String text) {
  final firstStrongCharacter = _strongCharacter.firstMatch(text)?.group(0);
  return firstStrongCharacter != null &&
          _rtlCharacter.hasMatch(firstStrongCharacter)
      ? TextDirection.rtl
      : TextDirection.ltr;
}
