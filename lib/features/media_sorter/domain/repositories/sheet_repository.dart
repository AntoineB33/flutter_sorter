import 'dart:math';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';

abstract class SheetRepository {
  Future<Point<int>> getLastSelectedCell();
  Future<void> saveLastSelectedCell(Point<int> cell);
  Future<String> getLastOpenedSheetName();
  Future<List<String>> getAllSheetNames();
  Future<SheetModel>
  loadSheet(String sheetName);
  Future<void> updateSheet(
    String sheetName,
    SheetModel sheet,
  );
  Future<void> saveLastOpenedSheetName(String sheetName);
  Future<void> saveAllSheetNames(List<String> sheetNames);
  Future<Map<String, Point<int>>> getAllLastSelected();
  Future<void> saveAllLastSelected(Map<String, Point<int>> cells);
  Future<void> clearAllData();
}
