import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';

class SaveSheetDataUseCase {
  final SheetRepository repository;

  SaveSheetDataUseCase(this.repository);

  Future<void> saveLastSelection(SelectionData selection) {
    return repository.saveLastSelection(selection);
  }

  Future<void> saveSheet(String sheetName, SheetData sheet) {
    return repository.updateSheet(sheetName, sheet);
  }

  Future<void> saveRecentSheetIds(List<String> sheetIds) {
    // Assuming the repository has a method to save the last opened sheet name
    return repository.saveRecentSheetIds(sheetIds);
  }

  Future<void> saveAllLastSelected(Map<String, SelectionData> cells) {
    return repository.saveAllLastSelected(cells);
  }

  Future<void> saveAllSortStatus(Map<String, SortStatus> sortStatusBySheet) {
    return repository.saveAllSortStatus(sortStatusBySheet);
  }

  Future<void> saveAnalysisResult(String sheetName, AnalysisResult result) {
    return repository.saveAnalysisResult(sheetName, result);
  }

  Future<void> saveSortProgression(String sheetName, SortProgressData data) {
    return repository.saveSortProgression(sheetName, data);
  }

  Future<void> clearAllData() {
    return repository.clearAllData();
  }
}
