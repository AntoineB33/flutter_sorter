import '../entities/spreadsheet_cell.dart';

abstract class SpreadsheetRepository {
  Future<void> updateCell(int row, int col, String value);
  Future<Map<(int, int), String>> getRegion(int startRow, int endRow);
}