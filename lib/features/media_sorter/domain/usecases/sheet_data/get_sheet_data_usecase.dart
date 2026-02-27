import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';

class GetSheetDataUseCase {
  final SheetRepository repository;

  GetSheetDataUseCase(this.repository);

  Future<Either<Failure, SelectionData>> getLastSelection() {
    return repository.getLastSelection();
  }

  Future<Either<Failure, List<String>>> recentSheetIds() {
    return repository.recentSheetIds();
  }

  Future<Either<Failure, Map<String, SelectionData>>> getAllLastSelected() async {
    return await repository.getAllLastSelected();
  }

  Future<Either<Failure, Map<String, SortStatus>>> getAllSortStatus() async {
    return await repository.getAllSortStatus();
  }

  Future<Either<Failure, AnalysisResult>> getAnalysisResult(String sheetName) async {
    return await repository.getAnalysisResult(sheetName);
  }

  Future<Either<Failure, SheetData>> loadSheet(String sheetName) {
    return repository.loadSheet(sheetName);
  }
}
