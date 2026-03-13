import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/helpers/utils_services.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_data_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sort_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/workbook_repository.dart';

class SortUsecase {
  final SortRepository sortRepository;
  final SheetDataRepository sheetDataRepository;
  final WorkbookRepository workbookRepository;

  Stream<Failure> get failureStream => sortRepository.failureStream;
  String get currentSheetId => workbookRepository.currentSheetId;

  SortUsecase(
    this.sortRepository,
    this.sheetDataRepository,
    this.workbookRepository,
  );

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

  bool isApplyBetterSortButtonLocked() {
    return sortRepository.isApplyBetterSortButtonLocked();
  }

  bool isBetterSortFound() {
    return sortRepository.isBetterSortFound();
  }

  bool isApplyBetterSortButtonInAction() {
    return sortRepository.isApplyBetterSortButtonInAction();
  }

  void applyBetterSortButton() {
    sortRepository.applyBetterSortButton();
  }

  void findBestSortToggle() {
    sortRepository.findBestSortToggle();
  }

  bool showApplySortToggle() {
    return sortRepository.showApplySortToggle();
  }

  void applySortToggle() {
    sortRepository.applySortToggle();
  }

  Stream<SortProgressDataMsg> calculateOnChange(String sheetId) {
    return sortRepository.lightCalculations(sheetId);
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

  bool getToApplyNextSort(String sheetId) {
    return sortRepository.getToApplyNextSort(sheetId);
  }

  bool getToApplyOnce(String sheetId) {
    return sortRepository.getToApplyNextSort(sheetId);
  }

  void setToApplyOnce(String sheetId, bool toApplyOnce) {
    sortRepository.setToApplyOnce(sheetId, toApplyOnce);
  }

  List<UpdateUnit> sortTable(String sheetId) {
    return sortRepository.sortMedia(sheetId);
  }

  Future<void> init() async {
    Either<Failure, void> result;
    result = await sortRepository.loadSortStatus();
    UtilsServices.handleDataCorruption(result);
  }
}
