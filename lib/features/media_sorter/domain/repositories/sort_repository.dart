import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class SortRepository {
  bool isReordering(int sheetId);
  bool getAnalysisDone(int sheetId);
  Future<void> analyze(int sheetId);
  List<int> getSheetIds();
  Future<Either<Failure, void>> loadSortStatus();
  bool getToApplyOnce(int sheetId);
  bool isCalculating(int sheetId);
  bool isCurrentBestSortAlwaysApplied(int sheetId);
  bool willNextBestSortBeApplied(int sheetId);
  bool isFindingBestSort(int sheetId);
  void setToApplyOnce(int sheetId, bool toApplyOnce);
  void setSortedWithCurrentBestSort(int sheetId, bool value);
  bool isSortedWithValidSort(int sheetId);
  bool handleSortProgressDataMsg(
    SortProgressDataMsg sortProgressDataMsg,
    int sheetId,
  );
  Map<String, UpdateUnit> sortTableWithCurrentBestSort(int sheetId);
  void lightCalculations(int sheetId);
  Future<Stream<SortProgressDataMsg>> launchCalculation(int sheetId);
  bool canFindBetterSort(int sheetId);
  bool isApplyBetterSortButtonLocked();
  bool sortedWithCurrentBestSort(int sheetId);
  bool isApplyBetterSortButtonInAction();
  void setToAlwaysApplyBestSort(int sheetId, bool toAlwaysApply);
  void removeSortStatus(int sheetId);
  void addNewAnalysisResult(int sheetId);
  void setFindingBestSort(int sheetId, bool value);
}
