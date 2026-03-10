import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';

class SortUsecase {
  final SortRepository sortRepository;
  final SheetDataRepository sheetDataRepository;

  Stream<void> get progressStream => sortRepository.progressStream;
  Stream<void> get sortStatusStream => sortRepository.sortStatusStream;
  Stream<void> get saveStream => sortRepository.saveStream;

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

  Future<void> calculateOnChange(String sheetId) async {
    await for (final SortProgressDataMsg sortProgressDataMsg in sortRepository.calculateOnChange()) {
      _handleSortProgressDataMsg(sortProgressDataMsg, sheetId);
    }
  }

  void _handleSortProgressDataMsg(SortProgressDataMsg sortProgressDataMsg, String sheetId) {
    sortRepository.handleSortProgressDataMsg(sortProgressDataMsg, sheetId);
    if (sortProgressDataMsg.newBestSortFound) {
      final List<UpdateUnit> updates = sortRepository.sortMedia(sheetId);
      sheetDataRepository.update(updates, sheetId);
      gridRepository.adjustRowHeightAfterUpdate(updates, sheetId);
      historyRepository.commitHistory(updates, sheetId);
    }
  }

  
  Future<Either<Failure, AnalysisResult>> getAnalysisResult(
    String sheetName,
  ) async {
    return await repository.getAnalysisResult(sheetName);
  }
}