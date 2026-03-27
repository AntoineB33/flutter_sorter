import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/utils_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/utils_services.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/selection_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';

class SortUsecase {
  final SortRepository sortRepository;
  final SheetDataRepository sheetDataRepository;
  final WorkbookRepository workbookRepository;
  final SelectionRepository selectionRepository;

  Stream<Failure> get failureStream => sortRepository.failureStream;
  int get currentSheetId => workbookRepository.currentSheetId;

  SortUsecase(
    this.sortRepository,
    this.sheetDataRepository,
    this.workbookRepository,
    this.selectionRepository,
  );

  Future<void> loadAnalysisResult(int sheetId) async {
    Either<Failure, void> result;
    result = await sortRepository.loadAnalysisResult(sheetId);
    UtilsServices.handleDataCorruption(result);
  }

  bool isSorting() {
    return sortRepository.isSorting(currentSheetId);
  }

  bool getAnalysisDone(int sheetId) {
    return sortRepository.getAnalysisDone(sheetId);
  }

  Future<void> analyze(int sheetId) {
    return sortRepository.analyze(sheetId);
  }

  void lightCalculations(int sheetId) {
    sortRepository.lightCalculations(sheetId);
  }

  List<String> getSheetIds() {
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
    FindBestSortChg findBestSortChg = FindBestSortChg(
      sheetId,
      value,
    );
    saveRepository.save({findBestSortChg.findingBestSortKey: findBestSortChg});
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
    return sortRepository.handleSortProgressDataMsg(
      sortProgressDataMsg,
      sheetId,
    );
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

  Map<Record, UpdateUnit> sortTableWithCurrentBestSort(int sheetId) {
    return sortRepository.sortTableWithCurrentBestSort(sheetId);
  }

  void loadSortStatus() {
    sortRepository.loadSortStatus();
  }
}
