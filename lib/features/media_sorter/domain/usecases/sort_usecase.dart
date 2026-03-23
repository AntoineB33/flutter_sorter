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
  String get currentSheetId => workbookRepository.currentSheetId;

  SortUsecase(
    this.sortRepository,
    this.sheetDataRepository,
    this.workbookRepository,
    this.selectionRepository,
  );

  Future<void> loadAnalysisResult(String sheetId) async {
    Either<Failure, void> result;
    result = await sortRepository.loadAnalysisResult(sheetId);
    UtilsServices.handleDataCorruption(result);
  }

  bool isSorting() {
    return sortRepository.isSorting(currentSheetId);
  }

  bool getAnalysisDone(String sheetId) {
    return sortRepository.getAnalysisDone(sheetId);
  }

  Future<void> analyze(String sheetId) {
    return sortRepository.analyze(sheetId);
  }

  void lightCalculations(String sheetId) {
    sortRepository.lightCalculations(sheetId);
  }

  List<String> getSheetIds() {
    return sortRepository.getSheetIds();
  }

  bool isSortedWithValidSort(String sheetId) {
    return sortRepository.isSortedWithValidSort(sheetId);
  }

  bool isApplyBetterSortButtonLocked() {
    return sortRepository.isApplyBetterSortButtonLocked();
  }

  bool sortedWithCurrentBestSort(String sheetId) {
    return sortRepository.sortedWithCurrentBestSort(sheetId);
  }

  bool isApplyBetterSortButtonInAction() {
    return sortRepository.isApplyBetterSortButtonInAction();
  }

  void setFindingBestSort(String sheetId, bool value) {
    sortRepository.setFindingBestSort(sheetId, value);
  }

  void setToAlwaysApplyBestSort(String sheetId, bool toAlwaysApply) {
    sortRepository.setToAlwaysApplyBestSort(sheetId, toAlwaysApply);
  }

  Future<Stream<SortProgressDataMsg>> launchCalculation(String sheetId) {
    return sortRepository.launchCalculation(sheetId);
  }

  bool handleSortProgressDataMsg(
    SortProgressDataMsg sortProgressDataMsg,
    String sheetId,
  ) {
    return sortRepository.handleSortProgressDataMsg(
      sortProgressDataMsg,
      sheetId,
    );
  }

  bool willNextBestSortBeApplied(String sheetId) {
    return sortRepository.willNextBestSortBeApplied(sheetId);
  }

  bool getToApplyOnce(String sheetId) {
    return sortRepository.getToApplyOnce(sheetId);
  }

  bool isCalculating(String sheetId) {
    return sortRepository.isCalculating(sheetId);
  }

  bool isFindingBestSort(String sheetId) {
    return sortRepository.isFindingBestSort(sheetId);
  }

  bool canFindBetterSort(String sheetId) {
    return sortRepository.canFindBetterSort(sheetId);
  }

  bool isCurrentBestSortAlwaysApplied(String sheetId) {
    return sortRepository.isCurrentBestSortAlwaysApplied(sheetId);
  }

  void setToApplyOnce(String sheetId, bool toApplyOnce) {
    sortRepository.setToApplyOnce(sheetId, toApplyOnce);
  }

  void setSortedWithCurrentBestSort(String sheetId, bool value) {
    sortRepository.setSortedWithCurrentBestSort(sheetId, value);
  }

  List<UpdateUnit> sortTableWithCurrentBestSort(String sheetId) {
    return sortRepository.sortTableWithCurrentBestSort(sheetId);
  }

  Future<void> loadSortStatus() async {
    Either<Failure, void> result;
    result = await sortRepository.loadSortStatus();
    result.fold(
      (failure) => UtilsServices.handleDataCorruption(Left(failure)),
      (ids) {
        bool sortStatusChanged = false;
        bool workbookSelectionCacheChanged = false;
        for (var sheetId in sortRepository.getSheetIds()) {
          if (!UtilsService.isValidSheetName(sheetId)) {
            sortRepository.removeSortStatus(sheetId);
            sortStatusChanged = true;
          } else if (!sheetDataRepository.containsSheetId(sheetId)) {
            workbookRepository.addNewSheetId(sheetId, 1);
            selectionRepository.setSelectionData(
              sheetId,
              SelectionData.empty(),
            );
            workbookSelectionCacheChanged = true;
          }
        }
        if (sortStatusChanged || workbookSelectionCacheChanged) {
          UtilsServices.handleDataCorruption(
            Left(
              CacheRepairedFailure(
                sortStatusChanged: sortStatusChanged,
                workbookCacheChanged: workbookSelectionCacheChanged,
                selectionCacheChanged: workbookSelectionCacheChanged,
              ),
            ),
          );
        }
      },
    );
  }
}
