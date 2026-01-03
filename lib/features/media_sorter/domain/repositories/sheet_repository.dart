import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';

abstract class SheetRepository {
  Future<void> createFile(String fileName);
  Future<SelectionModel> getLastSelection();
  Future<void> saveLastSelection(SelectionModel selection);
  Future<String> getLastOpenedSheetName();
  Future<List<String>> getAllSheetNames();
  Future<SheetModel> loadSheet(String sheetName);
  Future<void> updateSheet(String sheetName, SheetModel sheet);
  Future<void> saveLastOpenedSheetName(String sheetName);
  Future<void> saveAllSheetNames(List<String> sheetNames);
  Future<Map<String, SelectionModel>> getAllLastSelected();
  Future<void> saveAllLastSelected(Map<String, SelectionModel> cells);
  Future<void> clearAllData();
}
