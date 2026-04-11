import 'package:meta/meta.dart';
import 'package:trying_flutter/features/media_sorter/data/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';
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
    sortRepository.setFindingBestSort(sheetId, value);
    saveRepository.saveUpdate(
      SheetDataUpdate(sheetId, true, isFindingBestSort: value),
    );
  }

  void setToAlwaysApplyBestSort(int sheetId, bool toAlwaysApply) {
    final update = sortRepository.setToAlwaysApplyBestSort(sheetId, toAlwaysApply);
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

  @useResult
  ChangeSet sortTableWithCurrentBestSort(int sheetId) {
    return sortRepository.sortTableWithCurrentBestSort(sheetId);
  }

  void loadSortStatus() {
    sortRepository.loadSortStatus();
  }
}
