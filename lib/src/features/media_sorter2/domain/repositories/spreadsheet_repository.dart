import '../entities/cell.dart';

// Defines the contract for interacting with spreadsheet data
abstract class SpreadsheetRepository {
  /// Retrieves all cells for a specific sheet ID mapped by "row:col" key.
  Future<Map<String, Cell>> getSheet(String sheetId);

  /// Updates a specific cell's value.
  Future<void> updateCell(String sheetId, int row, int col, String value);
}