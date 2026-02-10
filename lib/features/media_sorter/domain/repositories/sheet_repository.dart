import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';

abstract class SheetRepository {
  Future<SelectionData> getLastSelection();
  Future<void> saveLastSelection(SelectionData selection);
  Future<String?> getLastOpenedSheetName();
  Future<List<String>> getAllSheetNames();
  Future<SheetData> loadSheet(String sheetName);
  Future<void> updateSheet(String sheetName, SheetData sheet);
  Future<void> saveLastOpenedSheetName(String sheetName);
  Future<void> saveAllSheetNames(List<String> sheetNames);
  Future<Map<String, SelectionData>> getAllLastSelected();
  Future<void> saveAllLastSelected(Map<String, SelectionData> cells);
  Future<AnalysisResult> getAnalysisResult(String sheetName);
  Future<void> saveAnalysisResult(String sheetName, AnalysisResult result);
  Future<void> clearAllData();
}
