import 'dart:math';

abstract class SheetRepository {
  Future<String> getLastOpenedSheetName();
  Future<List<String>> getAllSheetNames();
  Future<(List<List<String>> table, List<String> columnTypes, Point<int>, Point<int>)> loadSheet(String sheetName);
  Future<void> updateSheet(String sheetName, List<List<String>> table, List<String> columnTypes, Point<int> selectionStart, Point<int> selectionEnd);
  Future<void> saveLastOpenedSheetName(String sheetName);
  Future<void> saveAllSheetNames(List<String> sheetNames);
  Future<void> clearAllData();
}