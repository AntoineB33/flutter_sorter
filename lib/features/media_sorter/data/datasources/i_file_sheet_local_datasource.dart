import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';

abstract class IFileSheetLocalDataSource {
  Future<SelectionData> getLastSelection();
  Future<void> saveLastSelection(SelectionData selection);
  Future<List<String>> recentSheetIds();
  Future<void> saveRecentSheetIds(List<String> sheetIds);
  Future<Map<String, SelectionData>> getAllLastSelected();
  Future<void> saveAllLastSelected(Map<String, SelectionData> cells);
  Future<Map<String, SortStatus>> getAllSortStatus();
  Future<void> saveAllSortStatus(Map<String, SortStatus> sortStatusBySheet);
  Future<AnalysisResult> getAnalysisResult(String sheetId);
  Future<void> saveAnalysisResult(String sheetId, AnalysisResult result);
  Future<SheetData> getSheet(String sheetId);
  Future<void> saveSheet(String sheetId, SheetData sheet);
  Future<SortProgressData> getSortProgression(String sheetId);
  Future<void> saveSortProgression(String sheetId, SortProgressData progressData);
  Future<void> clearAllData();
}
