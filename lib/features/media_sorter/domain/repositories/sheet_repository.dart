import '../entities/spreadsheet_cell.dart';

abstract class SheetRepository {
  Future<String> getLastOpenedSheetName();
  Future<List<String>> getAllSheetNames();
  Future<Map<String, dynamic>> loadSheet(String sheetName);
  Future<void> updateSheet(String sheetName, List<List<String>> table, List<String> columnTypes);
  Future<void> saveLastOpenedSheetName(String sheetName);
  Future<void> saveAllSheetNames(List<String> sheetNames);
}