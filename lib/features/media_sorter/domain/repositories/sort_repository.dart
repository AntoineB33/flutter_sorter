import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/failures.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/sort_status.dart';

abstract class SortRepository {
  Map<int, SortStatus> get sortStatusBySheet;
  bool isReordering(int sheetId);
  bool getAnalysisDone(int sheetId);
  bool getBestSortPossibleFound(int sheetId);
  
  Future<void> analyze(int sheetId);
  Future<Either<Failure, void>> loadSortStatus();
  bool getToApplyOnce(int sheetId);
  bool isCalculating(int sheetId);
  bool willNextBestSortBeApplied(int sheetId);
  bool isFindingBestSort(int sheetId);
  void setToApplyOnce(int sheetId, bool toApplyOnce);
  void setSortedWithCurrentBestSort(int sheetId, bool value);
  bool isSortedWithValidSort(int sheetId);
  
  List<SyncRequest> handleSortProgressDataMsg(
    SortProgressDataMsg sortProgressDataMsg,
    int sheetId,
  );
  bool stopLoop(SortProgressDataMsg sortProgressDataMsg, int sheetId);
  
  List<SyncRequest> sortTableWithCurrentBestSort(int sheetId);
  Future<Stream<SortProgressDataMsg>> launchCalculation(int sheetId);
  bool betterSortNotImpossible(int sheetId);
  bool isCurrentBestSortAlwaysApplied(int sheetId);
  bool isReorderBetterButtonLocked();
  bool sortedWithCurrentBestSort(int sheetId);
  
  List<SyncRequest> setToAlwaysApplyBestSort(int sheetId, bool toAlwaysApply);
  
  void removeSortStatus(int sheetId);
  
  List<SyncRequest> addSheetId(int sheetId);
  
  List<SyncRequest> setFindingBestSort(int sheetId, bool value);
}
