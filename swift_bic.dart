class SwiftBic {
  // Format: 8 or 11: 4 letters bank + 2 letters country + 2 alnum location + 3 alnum branch (optional)
  static final _re = RegExp(r'^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?\$');

  static bool isFormatValid(String bic) => _re.hasMatch(bic.toUpperCase());

  // Partial known list (examples). Format validation is primary gate.
  static const known = {
    'NBOKKWKW': 'National Bank of Kuwait',
    'BRGNKWKW': 'Burgan Bank',
    'GULBKWKW': 'Gulf Bank',
    'ABKKKWKW': 'Al Ahli Bank of Kuwait',
    'BBYNKWKW': 'Boubyan Bank', // example code
  };

  static bool isKnownOrFormat(String bic) {
    final b = bic.toUpperCase();
    if (known.containsKey(b)) return true;
    return isFormatValid(b);
  }
}
