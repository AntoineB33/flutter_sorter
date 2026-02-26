import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';

class SheetRepositoryImpl implements SheetRepository {
  final FileSheetLocalDataSource dataSource;

  SheetRepositoryImpl(this.dataSource);

  @override
  Future<SelectionData> getLastSelection() async {
    return await dataSource.getLastSelection();
  }

  @override
  Future<void> saveLastSelection(SelectionData selection) async {
    await dataSource.saveLastSelection(selection);
  }

  @override
  Future<List<String>> recentSheetIds() async {
    return await dataSource.recentSheetIds();
  }

  @override
  Future<void> saveRecentSheetIds(List<String> sheetIds) async {
    await dataSource.saveRecentSheetIds(sheetIds);
  }

  @override
  Future<SheetData> loadSheet(String sheetName) async {
    return await dataSource.getSheet(sheetName);
  }

  @override
  Future<void> updateSheet(String sheetName, SheetData sheet) async {
    return await dataSource.saveSheet(sheetName, sheet);
  }

  @override
  Future<Map<String, SelectionData>> getAllLastSelected() async {
    return await dataSource.getAllLastSelected();
  }

  @override
  Future<void> saveAllLastSelected(Map<String, SelectionData> cells) async {
    await dataSource.saveAllLastSelected(cells);
  }

  @override
  Future<Map<String, SortStatus>> getAllSortStatus() async {
    return await dataSource.getAllSortStatus();
  }

  @override
  Future<void> saveAllSortStatus(
    Map<String, SortStatus> sortStatusBySheet,
  ) async {
    await dataSource.saveAllSortStatus(sortStatusBySheet);
  }

  @override
  Future<AnalysisResult> getAnalysisResult(String sheetName) async {
    return await dataSource.getAnalysisResult(sheetName);
  }

  @override
  Future<void> saveAnalysisResult(
    String sheetName,
    AnalysisResult result,
  ) async {
    await dataSource.saveAnalysisResult(sheetName, result);
  }

  @override
  Future<SortProgressData> getSortProgression(String sheetName) async {
    return await dataSource.getSortProgression(sheetName);
  }

  @override
  Future<void> saveSortProgression(
    String sheetName,
    SortProgressData progress,
  ) async {
    await dataSource.saveSortProgression(sheetName, progress);
  }

  @override
  Future<void> clearAllData() async {
    await dataSource.clearAllData();
  }
}
