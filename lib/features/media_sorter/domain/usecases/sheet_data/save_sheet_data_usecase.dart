import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data/sheet_save_repository.dart';

class SaveSheetDataUseCase {
  final SheetSaveRepository sheetSaveRepository;
  final SelectionRepository selectionRepository;
  final SheetDataRepository sheetDataRepository;

  SaveSheetDataUseCase(this.sheetSaveRepository, this.selectionRepository, this.sheetDataRepository);


  Future<void> saveSheet(String sheetName, SheetData sheet) {
    return sheetSaveRepository.updateSheet(sheetName, sheet);
  }

  Future<void> saveRecentSheetIds() {
    // Assuming the repository has a method to save the last opened sheet name
    return sheetSaveRepository.saveRecentSheetIds();
  }

  Future<void> saveAllLastSelected(Map<String, SelectionData> cells) {
    return sheetSaveRepository.saveAllLastSelected(cells);
  }

  Future<void> saveAllSortStatus(Map<String, SortStatus> sortStatusBySheet) {
    return sheetSaveRepository.saveAllSortStatus(sortStatusBySheet);
  }

  Future<void> saveAnalysisResult(String sheetName, AnalysisResult result) {
    return sheetSaveRepository.saveAnalysisResult(sheetName, result);
  }

  Future<void> saveSortProgression(String sheetName, SortProgressData data) {
    return sheetSaveRepository.saveSortProgression(sheetName, data);
  }

  Future<void> clearAllData() {
    return sheetSaveRepository.clearAllData();
  }
}
