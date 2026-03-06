import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';

class SortUsecase {
  final SortRepository sortRepository;
  final SheetDataRepository sheetDataRepository;

  String get currentSheetId => sheetDataRepository.currentSheetId;
  Stream<void> get progressStream => sortRepository.progressStream;
  Stream<void> get sortStatusStream => sortRepository.sortStatusStream;

  SortUsecase(this.sortRepository, this.sheetDataRepository);

  void sortMedia(String sheetId) {
    sortRepository.sortMedia(sheetId);
  }

  void onDataProgressUpdate() {
    sortRepository.saveDataProgress();
    if (sortRepository.toSort(currentSheetId) && sortRepository.sortedWithValidSort(currentSheetId)) {
      sortRepository.sortMedia(currentSheetId);
    }
  }

  void saveSortStatus() {
    sortRepository.saveAllSortStatus();
  }

  void calculateOnChange() {
    sortRepository.calculateOnChange();
  }

  
  Future<Either<Failure, AnalysisResult>> getAnalysisResult(
    String sheetName,
  ) async {
    return await repository.getAnalysisResult(sheetName);
  }
}