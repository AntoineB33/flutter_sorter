class SpreadsheetConstants {
  // Prevent instantiation
  const SpreadsheetConstants._();

  static const patternDistance =
    r'^(?<prefix>as far as possible from )(?<any>any)?(?<att>.+)$/';
  static const patternAreas =
    r'^(?<prefix>.*\|)(?<any>any)?(?<att>.+)(?<suffix>\|.*)$/';
  static const all = -1;
  static const notUsedCst = -2;

  static const refFromAttColMsg = "rows that have it as attribute";
  static const refFromDepColMsg = "rows that have constraints based on it";
}