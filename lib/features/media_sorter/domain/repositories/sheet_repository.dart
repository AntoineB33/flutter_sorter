import '../entities/spreadsheet_cell.dart';

abstract class SheetRepository {
  Future<String> getLastOpenedSheetName();
  Future<Map<String, dynamic>> loadSheet(String sheetName);
  Future<void> updateSheet(String sheetName, List<List<String>> table, List<String> columnTypes);
}