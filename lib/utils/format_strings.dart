String intFormat(int number) {
  String numberStr = number.toString();

  for (int i = 3; i < numberStr.length; i += 3) {
    final mid = numberStr.length - i;
    numberStr = '${numberStr.substring(0, mid)},${numberStr.substring(mid)}';
    ++i;
  }

  return numberStr;
}
