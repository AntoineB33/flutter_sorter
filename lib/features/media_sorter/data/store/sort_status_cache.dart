import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';

class SortStatusCache {
  final Map<String, SortStatus> _sortStatusBySheet = {};

  final LoadedSheetsCache loadedSheetsDataStore;

  SortStatusCache(this.loadedSheetsDataStore);

  Map<String, SortStatus> get sortStatusBySheet => _sortStatusBySheet;

  bool isSorting(String sheetId) {
    return containsSheet(sheetId) &&
        (_sortStatusBySheet[sheetId]!.toApplyNextBestSort ||
            _sortStatusBySheet[sheetId]!.toAlwaysApplyCurrentBestSort);
  }

  bool containsSheet(String sheetId) {
    return _sortStatusBySheet.containsKey(sheetId);
  }

  bool getToApplyOnce(String sheetId) {
    return _sortStatusBySheet[sheetId]?.toApplyNextBestSort ?? false;
  }

  bool willNextBestSortBeApplied(String sheetId) {
    return _sortStatusBySheet[sheetId]!.toApplyNextBestSort ||
        _sortStatusBySheet[sheetId]!.toAlwaysApplyCurrentBestSort;
  }

  List<String> getSheetIds() {
    return _sortStatusBySheet.keys.toList();
  }

  bool getAnalysisDone(String sheetId) {
    return _sortStatusBySheet[sheetId]?.analysisDone ?? false;
  }

  bool isCurrentBestSortAlwaysApplied(String sheetId) {
    return _sortStatusBySheet[sheetId]?.toAlwaysApplyCurrentBestSort ?? false;
  }

  void setToApplyOnce(String sheetId, bool value) {
    if (_sortStatusBySheet.containsKey(sheetId)) {
      _sortStatusBySheet[sheetId]!.toApplyNextBestSort = value;
    }
  }

  void setToAlwaysApplyBestSort(String sheetId, bool toAlwaysApply) {
    if (_sortStatusBySheet.containsKey(sheetId)) {
      _sortStatusBySheet[sheetId]!.toAlwaysApplyCurrentBestSort = toAlwaysApply;
    }
  }

  void isAnalysing(String sheetId) {
    _sortStatusBySheet[sheetId] = SortStatus(analysisDone: false);
  }

  void analysisIsDone(String sheetId, bool toFindValidSort) {
    if (toFindValidSort) {
      _sortStatusBySheet[sheetId]!.analysisDone = true;
    } else {
      removeSortStatus(sheetId);
    }
  }

  void setSortStatus(Map<String, SortStatus> statuses) {
    _sortStatusBySheet
      ..clear()
      ..addAll(statuses);
  }

  void removeSortStatus(String sheetId) {
    if (_sortStatusBySheet.containsKey(sheetId)) {
      _sortStatusBySheet.remove(sheetId);
    }
  }
}
