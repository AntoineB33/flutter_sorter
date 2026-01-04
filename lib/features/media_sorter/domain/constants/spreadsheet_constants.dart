class SpreadsheetConstants {
  // Prevent instantiation
  const SpreadsheetConstants._();

  static const patternDistance =
      r'^(?<prefix>as far as possible from )(?<any>any)?(?<att>.+)$';
  static const patternAreas =
      r'^(?<prefix>.*\|)(?<any>any)?(?<att>.+)(?<suffix>\|.*)$';
  static const all = -1;
  static const notUsedCst = -2;

  static const errorMsg = 'Error Log';
  static const warningMsg = 'Warning Log';
  static const selectionMsg = 'Current Selection';
  static const searchMsg = 'Search Results';
  static const categoryMsg = 'Categories';
  static const distPairsMsg = 'Distance Pairs';
  static const nodeAttributeMsg = 'attribute';
  static const cell = 'cell';
  static const row = 'row';
  static const column = 'column';
  static const cycleDetected = 'Cycle detected';
  static const attToCol = 'Columns with this attribute';
  static const refFromAttColMsg = "rows that have it as attribute";
  static const attToRefFromDepCol = "rows that mention this attribute";
  static const moveToUniqueMentionSprawlCol =
      "moved to unique mention in sprawl column for this attribute";
  static const refFromDepColMsg = "rows that have constraints based on it";

  static const noSPNameFound = 'No Spreadsheet Name Found';
  static const defaultSheetName = 'Sheet1';

  static const folderName = 'media_sorter';
  static const sheetsIndexFileName = 'sheets_index.json';
  static const allLastSelectedFileName = 'all_last_selected.json';
  static const lastOpenedSheetNameKey = 'lastOpenedSheetName';
  static const lastSelectedCellKey = 'lastSelectedCell';

  // static const debugDelayMs = 500000000;
  static const debugDelayMs = 0;
}
