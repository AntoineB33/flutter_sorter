import '../entities/spreadsheet_cell.dart';

abstract class SheetRepository {
  Future<String> getLastOpenedSheetName();
  Future<(List<List<String>>, List<String>)> loadSheet(String sheetName);
  Future<void> updateSheet(String sheetName, List<List<String>> data);
}