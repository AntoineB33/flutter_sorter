class SpreadsheetConstants {
  // Prevent instantiation
  const SpreadsheetConstants._();

  static const patternDistance =
    r'^(?<prefix>as far as possible from )(?<any>any)?(?<att>.+)$/';
  static const patternAreas =
    r'^(?<prefix>.*\|)(?<any>any)?(?<att>.+)(?<suffix>\|.*)$/';
  static const rowCst = "rows";
  static const notUsedCst = "notUsed";
}