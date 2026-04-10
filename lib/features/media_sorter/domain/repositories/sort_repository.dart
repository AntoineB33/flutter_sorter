import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/data/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sort_progress_data.dart';

abstract class SortRepository {
  bool isReordering(int sheetId);
  bool getAnalysisDone(int sheetId);
  bool getBestSortPossibleFound(int sheetId);
  Future<void> analyze(int sheetId);
  List<int> getSheetIds();
  Future<Either<Failure, void>> loadSortStatus();
  bool getToApplyOnce(int sheetId);
  bool isCalculating(int sheetId);
  bool willNextBestSortBeApplied(int sheetId);
  bool isFindingBestSort(int sheetId);
  void setToApplyOnce(int sheetId, bool toApplyOnce);
  void setSortedWithCurrentBestSort(int sheetId, bool value);
  bool isSortedWithValidSort(int sheetId);
  @useResult
  ChangeSet handleSortProgressDataMsg(
    SortProgressDataMsg sortProgressDataMsg,
    int sheetId,
  );
  bool stopLoop(SortProgressDataMsg sortProgressDataMsg, int sheetId);
  @useResult
  ChangeSet sortTableWithCurrentBestSort(int sheetId);
  Future<Stream<SortProgressDataMsg>> launchCalculation(int sheetId);
  bool betterSortNotImpossible(int sheetId);
  bool isCurrentBestSortAlwaysApplied(int sheetId);
  bool isReorderBetterButtonLocked();
  bool sortedWithCurrentBestSort(int sheetId);
  void setToAlwaysApplyBestSort(int sheetId, bool toAlwaysApply);
  void removeSortStatus(int sheetId);
  void addNewAnalysisResult(int sheetId);
  void setFindingBestSort(int sheetId, bool value);
}
