import 'package:meta/meta.dart';
import 'package:trying_flutter/features/media_sorter/data/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/save_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';

class SortUsecase {
  final SaveRepository saveRepository;

  final SortRepository sortRepository;
  final SheetDataRepository sheetDataRepository;
  final WorkbookRepository workbookRepository;
  final SelectionRepository selectionRepository;

  int get currentSheetId => workbookRepository.currentSheetId;
  Map<int, SortStatus> get sortStatusBySheet =>
      sortRepository.sortStatusBySheet;

  SortUsecase(
    this.saveRepository,
    this.sortRepository,
    this.sheetDataRepository,
    this.workbookRepository,
    this.selectionRepository,
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
    final result = sortRepository.setFindingBestSort(sheetId, value);
    saveRepository.save(result);
  }

  void setToAlwaysApplyBestSort(int sheetId, bool toAlwaysApply) {
    final update = sortRepository.setToAlwaysApplyBestSort(
      sheetId,
      toAlwaysApply,
    );
    saveRepository.save(update);
  }

  Future<Stream<SortProgressDataMsg>> launchCalculation(int sheetId) {
    return sortRepository.launchCalculation(sheetId);
  }

  bool handleSortProgressDataMsg(
    SortProgressDataMsg sortProgressDataMsg,
    int sheetId,
  ) {
    ChangeSet changeSet = sortRepository.handleSortProgressDataMsg(
      sortProgressDataMsg,
      sheetId,
    );
    saveRepository.save(changeSet);
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

  
  ChangeSet sortTableWithCurrentBestSort(int sheetId) {
    return sortRepository.sortTableWithCurrentBestSort(sheetId);
  }

  Future<void> loadSortStatus() async {
    await sortRepository.loadSortStatus();
  }
}
