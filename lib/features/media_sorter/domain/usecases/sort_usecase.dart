import 'package:trying_flutter/features/media_sorter/domain/models/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';

class SortUsecase {
  final SortRepository sortRepository;
  final SheetDataRepository sheetDataRepository;
  final WorkbookRepository workbookRepository;
  final SelectionRepository selectionRepository;
  final HistoryRepository historyRepository;

  int get currentSheetId => workbookRepository.currentSheetId;
  Map<int, SortStatus> get sortStatusBySheet =>
      sortRepository.sortStatusBySheet;

  SortUsecase(
    this.sortRepository,
    this.sheetDataRepository,
    this.workbookRepository,
    this.selectionRepository,
    this.historyRepository,
  );

  bool isReordering() {
    return sortRepository.isReordering(currentSheetId);
  }

  bool getAnalysisDone(int sheetId) {
    return sortRepository.getAnalysisDone(sheetId);
  }

  bool getBestSortPossibleFound(int sheetId) {
    return sortRepository.getBestSortPossibleFound(sheetId);
  }

  Future<void> analyze(int sheetId) {
    return sortRepository.analyze(sheetId);
  }

  bool isSortedWithValidSort(int sheetId) {
    return sortRepository.isSortedWithValidSort(sheetId);
  }

  bool isReorderBetterButtonLocked() {
    return sortRepository.isReorderBetterButtonLocked();
  }

  bool sortedWithCurrentBestSort(int sheetId) {
    return sortRepository.sortedWithCurrentBestSort(sheetId);
  }

  void setFindingBestSort(int sheetId, bool value) {
    sortRepository.setFindingBestSort(sheetId, value);
    historyRepository.scheduleCommit();
  }

  void setToAlwaysApplyBestSort(int sheetId, bool toAlwaysApply) {
    sortRepository.setToAlwaysApplyBestSort(
      sheetId,
      toAlwaysApply,
    );
    historyRepository.scheduleCommit();
  }

  Future<Stream<SortProgressDataMsg>> launchCalculation(int sheetId) {
    return sortRepository.launchCalculation(sheetId);
  }

  bool handleSortProgressDataMsg(
    SortProgressDataMsg sortProgressDataMsg,
    int sheetId,
  ) {
    sortRepository.handleSortProgressDataMsg(
      sortProgressDataMsg,
      sheetId,
    );
    historyRepository.scheduleCommit();
    return sortRepository.stopLoop(sortProgressDataMsg, sheetId);
  }

  bool willNextBestSortBeApplied(int sheetId) {
    return sortRepository.willNextBestSortBeApplied(sheetId);
  }

  bool getToApplyOnce(int sheetId) {
    return sortRepository.getToApplyOnce(sheetId);
  }

  bool isCalculating(int sheetId) {
    return sortRepository.isCalculating(sheetId);
  }

  bool isFindingBestSort(int sheetId) {
    return sortRepository.isFindingBestSort(sheetId);
  }

  bool canFindBetterSort(int sheetId) {
    return sortRepository.betterSortNotImpossible(sheetId);
  }

  bool isCurrentBestSortAlwaysApplied(int sheetId) {
    return sortRepository.isCurrentBestSortAlwaysApplied(sheetId);
  }

  void setToApplyOnce(int sheetId, bool toApplyOnce) {
    sortRepository.setToApplyOnce(sheetId, toApplyOnce);
  }

  void setSortedWithCurrentBestSort(int sheetId, bool value) {
    sortRepository.setSortedWithCurrentBestSort(sheetId, value);
  }

  void sortTableWithCurrentBestSort(int sheetId) {
    sortRepository.sortTableWithCurrentBestSort(sheetId);
  }

  Future<void> loadSortStatus() async {
    await sortRepository.loadSortStatus();
  }
}
