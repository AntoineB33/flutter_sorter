import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';

abstract class IFileSheetLocalDataSource {
  Future<SelectionData> getLastSelection();
  Future<void> saveLastSelection(SelectionData selection);
  Future<String?> getLastOpenedSheetName();
  Future<void> saveLastOpenedSheetName(String sheetName);
  Future<List<String>> getAllSheetNames();
  Future<void> saveAllSheetNames(List<String> sheetNames);
  Future<Map<String, SelectionData>> getAllLastSelected();
  Future<void> saveAllLastSelected(Map<String, SelectionData> cells);
  Future<Map<String, SortStatus>> getAllSortStatus();
  Future<void> saveAllSortStatus(Map<String, SortStatus> sortStatusBySheet);
  Future<AnalysisResult> getAnalysisResult(String sheetName);
  Future<void> saveAnalysisResult(String sheetName, AnalysisResult result);
  Future<void> clearAllData();
  Future<SheetData> getSheet(String sheetName);
  Future<void> saveSheet(String sheetName, SheetData sheet);
}
