class Iban {
  // Validate IBAN by moving first 4 chars to end and mod-97 == 1
  static bool isValid(String iban) {
    final s = iban.replaceAll(' ', '').toUpperCase();
    if (s.length < 5) return false;
    final rearranged = s.substring(4) + s.substring(0,4);
    final numeric = rearranged.split('').map((c) {
      final code = c.codeUnitAt(0);
      if (code >= 65 && code <= 90) {
        return (code - 55).toString(); // A=10
      } else if (code >= 48 && code <= 57) {
        return c;
      } else {
        return '';
      }
    }).join();
    return _mod97(numeric) == 1;
  }

  static int _mod97(String s) {
    int remainder = 0;
    for (int i=0; i<s.length; i+=7) {
      final part = remainder.toString() + s.substring(i, i+7 > s.length ? s.length : i+7);
      remainder = int.parse(part) % 97;
    }
    return remainder;
  }
}
