import 'dart:math';

abstract class SheetRepository {
  Future<Point<int>> getLastSelectedCell();
  Future<void> saveLastSelectedCell(Point<int> cell);
  Future<String> getLastOpenedSheetName();
  Future<List<String>> getAllSheetNames();
  Future<(List<List<String>> table, List<String> columnTypes, int tableHeight, int tableWidth)> loadSheet(String sheetName);
  Future<void> updateSheet(String sheetName, List<List<String>> table, List<String> columnTypes);
  Future<void> saveLastOpenedSheetName(String sheetName);
  Future<void> saveAllSheetNames(List<String> sheetNames);
  Future<Map<String, Point<int>>> getAllLastSelected();
  Future<void> saveAllLastSelected(Map<String, Point<int>> cells);
  Future<void> clearAllData();
}