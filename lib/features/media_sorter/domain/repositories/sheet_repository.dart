import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';

abstract class SheetRepository {
  Future<Either<Failure, SelectionData>> getLastSelection();
  Future<Either<Failure, void>> saveLastSelection(SelectionData selection);
  Future<Either<Failure, List<String>>> recentSheetIds();
  Future<Either<Failure, void>> saveRecentSheetIds(List<String> sheetIds);
  Future<Either<Failure, Map<String, SelectionData>>> getAllLastSelected();
  Future<Either<Failure, void>> saveAllLastSelected(Map<String, SelectionData> cells);
  Future<Either<Failure, Map<String, SortStatus>>> getAllSortStatus();
  Future<Either<Failure, void>> saveAllSortStatus(Map<String, SortStatus> sortStatusBySheet);
  Future<Either<Failure, AnalysisResult>> getAnalysisResult(String sheetName);
  Future<Either<Failure, void>> saveAnalysisResult(String sheetId, AnalysisResult result);
  Future<Either<Failure, SheetData>> loadSheet(String sheetId);
  Future<Either<Failure, void>> updateSheet(String sheetId, SheetData sheet);
  Future<Either<Failure, SortProgressData>> getSortProgression(String sheetId);
  Future<Either<Failure, void>> saveSortProgression(String sheetId, SortProgressData progressData);
  Future<void> clearAllData();
}
