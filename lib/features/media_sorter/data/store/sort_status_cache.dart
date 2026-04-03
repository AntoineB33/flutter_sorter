import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';

class SortStatusCache {
  final Map<int, SortStatus> _sortStatusBySheet = {};

  final LoadedSheetsCache loadedSheetsDataStore;

  SortStatusCache(this.loadedSheetsDataStore);

  Map<int, SortStatus> get sortStatusBySheet => _sortStatusBySheet;

  bool isReordering(int sheetId) {
    return containsSheet(sheetId) &&
        (_sortStatusBySheet[sheetId]!.toApplyNextBestSort ||
            _sortStatusBySheet[sheetId]!.toAlwaysApplyCurrentBestSort);
  }

  bool containsSheet(int sheetId) {
    return _sortStatusBySheet.containsKey(sheetId);
  }

  bool getToApplyOnce(int sheetId) {
    return _sortStatusBySheet[sheetId]?.toApplyNextBestSort ?? false;
  }

  bool willNextBestSortBeApplied(int sheetId) {
    return _sortStatusBySheet[sheetId]!.toApplyNextBestSort ||
        _sortStatusBySheet[sheetId]!.toAlwaysApplyCurrentBestSort;
  }

  List<int> getSheetIds() {
    return _sortStatusBySheet.keys.toList();
  }

  bool getAnalysIsDone(int sheetId) {
    return _sortStatusBySheet[sheetId]?.analysIsDone ?? false;
  }

  bool isCurrentBestSortAlwaysApplied(int sheetId) {
    return _sortStatusBySheet[sheetId]?.toAlwaysApplyCurrentBestSort ?? false;
  }

  void setToApplyOnce(int sheetId, bool value) {
    if (_sortStatusBySheet.containsKey(sheetId)) {
      _sortStatusBySheet[sheetId]!.copyWith(toApplyNextBestSort: value);
    }
  }

  void setToAlwaysApplyBestSort(int sheetId, bool toAlwaysApply) {
    if (_sortStatusBySheet.containsKey(sheetId)) {
      _sortStatusBySheet[sheetId]!.copyWith(toAlwaysApplyCurrentBestSort: toAlwaysApply);
    }
  }

  void isAnalysing(int sheetId) {
    _sortStatusBySheet[sheetId]!.copyWith(analysIsDone: false);
  }

  void analysisIsDone(int sheetId, bool toFindValidSort) {
    if (toFindValidSort) {
      _sortStatusBySheet[sheetId]!.copyWith(analysIsDone: true);
    } else {
      removeSortStatus(sheetId);
    }
  }

  void setSortStatus(Map<int, SortStatus> statuses) {
    _sortStatusBySheet
      ..clear()
      ..addAll(statuses);
  }

  void removeSortStatus(int sheetId) {
    if (_sortStatusBySheet.containsKey(sheetId)) {
      _sortStatusBySheet.remove(sheetId);
    }
  }
}
