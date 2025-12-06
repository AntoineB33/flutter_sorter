import '../entities/spreadsheet_cell.dart';

abstract class SpreadsheetRepository {
  Future<List<SpreadsheetCell>> loadSheet();
  Future<void> saveSheet(List<SpreadsheetCell> cells);
  Future<void> updateCell(int row, int col, String value);
}