import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';

class GetSheetDataUseCase {
  final SheetRepository repository;

  GetSheetDataUseCase(this.repository);

  Future<SelectionData> getLastSelection() {
    return repository.getLastSelection();
  }

  Future<List<String>> recentSheetIds() {
    return repository.recentSheetIds();
  }

  Future<Map<String, SelectionData>> getAllLastSelected() async {
    return await repository.getAllLastSelected();
  }

  Future<Map<String, SortStatus>> getAllSortStatus() async {
    return await repository.getAllSortStatus();
  }

  Future<AnalysisResult> getAnalysisResult(String sheetName) async {
    return await repository.getAnalysisResult(sheetName);
  }

  Future<SheetData> loadSheet(String sheetName) {
    return repository.loadSheet(sheetName);
  }
}
