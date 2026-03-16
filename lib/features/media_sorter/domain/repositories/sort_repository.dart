import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class SortRepository {
  Stream<Failure> get failureStream;
  bool isSorting(String sheetId);
  bool getAnalysisDone(String sheetId);
  Future<void> analyze(String sheetId);
  List<String> getSheetIds();
  Future<Either<Failure, void>> loadSortStatus();
  bool getToApplyNextSort(String sheetId);
  void setToApplyOnce(String sheetId, bool toApplyOnce);
  bool sortedWithValidSort(String sheetId);
  bool handleSortProgressDataMsg(
    SortProgressDataMsg sortProgressDataMsg,
    String sheetId,
  );
  List<UpdateUnit> sortMedia(String sheetId);
  void lightCalculations(String sheetId);
  Future<Stream<SortProgressDataMsg>> launchCalculation(String sheetId);
  void findBestSortToggle();
  bool showApplySortToggle();
  bool isApplyBetterSortButtonLocked();
  bool isBetterSortFound();
  bool isApplyBetterSortButtonInAction();
  void applyBetterSortButton();
  void applySortToggle();
  Future<Either<Failure, void>> loadAnalysisResult(String sheetId);
  void removeSortStatus(String sheetId);
  void addNewAnalysisResult(String sheetId);
}
