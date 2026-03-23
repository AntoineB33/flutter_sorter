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
  bool getToApplyOnce(String sheetId);
  bool isCalculating(String sheetId);
  bool isCurrentBestSortAlwaysApplied(String sheetId);
  bool willNextBestSortBeApplied(String sheetId);
  bool isFindingBestSort(String sheetId);
  void setToApplyOnce(String sheetId, bool toApplyOnce);
  void setSortedWithCurrentBestSort(String sheetId, bool value);
  bool isSortedWithValidSort(String sheetId);
  bool handleSortProgressDataMsg(
    SortProgressDataMsg sortProgressDataMsg,
    String sheetId,
  );
  List<UpdateUnit> sortTableWithCurrentBestSort(String sheetId);
  void lightCalculations(String sheetId);
  Future<Stream<SortProgressDataMsg>> launchCalculation(String sheetId);
  bool canFindBetterSort(String sheetId);
  bool isApplyBetterSortButtonLocked();
  bool sortedWithCurrentBestSort(String sheetId);
  bool isApplyBetterSortButtonInAction();
  void setToAlwaysApplyBestSort(String sheetId, bool toAlwaysApply);
  Future<Either<Failure, void>> loadAnalysisResult(String sheetId);
  void removeSortStatus(String sheetId);
  void addNewAnalysisResult(String sheetId);
  void setFindingBestSort(String sheetId, bool value);
}
