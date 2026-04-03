import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:trying_flutter/features/media_sorter/core/entities/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
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

  bool getAnalysIsDone(int sheetId) {
    return sortRepository.getAnalysIsDone(sheetId);
  }

  Future<void> analyze(int sheetId) {
    return sortRepository.analyze(sheetId);
  }

  List<int> getSheetIds() {
    return sortRepository.getSheetIds();
  }

  bool isSortedWithValidSort(int sheetId) {
    return sortRepository.isSortedWithValidSort(sheetId);
  }

  bool isApplyBetterSortButtonLocked() {
    return sortRepository.isApplyBetterSortButtonLocked();
  }

  bool sortedWithCurrentBestSort(int sheetId) {
    return sortRepository.sortedWithCurrentBestSort(sheetId);
  }

  bool isApplyBetterSortButtonInAction() {
    return sortRepository.isApplyBetterSortButtonInAction();
  }

  void setFindingBestSort(int sheetId, bool value) {
    sortRepository.setFindingBestSort(sheetId, value);
    saveRepository.saveUpdate(SheetDataUpdate(sheetId, true, isFindingBestSort: value));
  }

  void setToAlwaysApplyBestSort(int sheetId, bool toAlwaysApply) {
    sortRepository.setToAlwaysApplyBestSort(sheetId, toAlwaysApply);
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
    return sortRepository.canFindBetterSort(sheetId);
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

  IMap<String, UpdateUnit> sortTableWithCurrentBestSort(int sheetId) {
    return sortRepository.sortTableWithCurrentBestSort(sheetId);
  }

  void loadSortStatus() {
    sortRepository.loadSortStatus();
  }
}
