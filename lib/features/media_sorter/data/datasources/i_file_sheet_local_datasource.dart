import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';

abstract class IFileSheetLocalDataSource {
  Future<void> createFile(String fileName);
  Future<SelectionModel> getLastSelection();
  Future<void> saveLastSelection(SelectionModel selection);
  Future<String> getLastOpenedSheetName();
  Future<void> saveLastOpenedSheetName(String sheetName);
  Future<List<String>> getAllSheetNames();
  Future<void> saveAllSheetNames(List<String> sheetNames);
  Future<Map<String, SelectionModel>> getAllLastSelected();
  Future<void> saveAllLastSelected(Map<String, SelectionModel> cells);
  Future<void> clearAllData();
  Future<SheetModel> getSheet(String sheetName);
  Future<void> saveSheet(String sheetName, SheetModel sheet);
}