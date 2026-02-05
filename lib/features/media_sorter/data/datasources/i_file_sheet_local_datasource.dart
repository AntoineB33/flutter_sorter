import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';

abstract class IFileSheetLocalDataSource {
  Future<SelectionData> getLastSelection();
  Future<void> saveLastSelection(SelectionData selection);
  Future<String?> getLastOpenedSheetName();
  Future<void> saveLastOpenedSheetName(String sheetName);
  Future<List<String>> getAllSheetNames();
  Future<void> saveAllSheetNames(List<String> sheetNames);
  Future<Map<String, SelectionData>> getAllLastSelected();
  Future<void> saveAllLastSelected(Map<String, SelectionData> cells);
  Future<void> clearAllData();
  Future<SheetData> getSheet(String sheetName);
  Future<void> saveSheet(String sheetName, SheetData sheet);
}
