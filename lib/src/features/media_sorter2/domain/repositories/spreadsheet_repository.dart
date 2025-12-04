import '../../domain/entities/cell.dart';

abstract class SpreadsheetRepository {
  Future<Map<String, Cell>> loadSheet();
  Future<Cell> saveCell(int row, int col, String value);
}