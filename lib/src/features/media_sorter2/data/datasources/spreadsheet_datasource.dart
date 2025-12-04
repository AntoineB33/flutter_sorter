import '../../domain/entities/cell.dart';

// Abstract definition of the data source
abstract class SpreadsheetDataSource {
  Future<Map<String, Cell>> fetchSheetData(String sheetId);
  Future<void> saveCellData(String sheetId, int row, int col, String value);
}

// Implementation: In-Memory Storage
// This mocks a database by holding data in a static variable so it persists 
// even if the provider creates a new instance of the class.
class InMemorySpreadsheetDataSource implements SpreadsheetDataSource {
  // Key: sheetId, Value: Map of "row:col" -> Cell
  static final Map<String, Map<String, Cell>> _mockDatabase = {};

  @override
  Future<Map<String, Cell>> fetchSheetData(String sheetId) async {
    
    if (!_mockDatabase.containsKey(sheetId)) {
      _mockDatabase[sheetId] = {};
    }
    
    // Return a copy to prevent direct reference manipulation issues
    return Map<String, Cell>.from(_mockDatabase[sheetId]!);
  }

  @override
  Future<void> saveCellData(String sheetId, int row, int col, String value) async {

    if (!_mockDatabase.containsKey(sheetId)) {
      _mockDatabase[sheetId] = {};
    }

    final key = '$row:$col';
    _mockDatabase[sheetId]![key] = Cell(row: row, col: col, value: value);
    
    print('Saved to DB: Sheet $sheetId [$row,$col] = $value');
  }
}