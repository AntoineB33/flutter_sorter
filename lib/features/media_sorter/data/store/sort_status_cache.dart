
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';

class SortStatusCache {
  final Map<String, SortStatus> _sortStatusBySheet = {};

  final LoadedSheetsCache loadedSheetsDataStore;

  SortStatusCache(this.loadedSheetsDataStore);

  Map<String, SortStatus> get sortStatusBySheet => _sortStatusBySheet;

  bool containsSheet(String sheetId) {
    return _sortStatusBySheet.containsKey(sheetId);
  }

  bool getToApplyOnce(String sheetId) {
    return _sortStatusBySheet[sheetId]?.toApplyOnce ?? false;
  }

  List<String> getSheetIds() {
    return _sortStatusBySheet.keys.toList();
  }

  bool getAnalysisDone(String sheetId) {
    return _sortStatusBySheet[sheetId]?.analysisDone ?? false;
  }

  bool getToAlwaysApply(String sheetId) {
    return _sortStatusBySheet[sheetId]?.toAlwaysApply ?? false;
  }

  void setToApplyOnce(String sheetId, bool toSortOnce) {
    if (_sortStatusBySheet.containsKey(sheetId)) {
      _sortStatusBySheet[sheetId]!.toApplyOnce = toSortOnce;
    }
  }

  void setToAlwaysApply(String sheetId, bool toAlwaysApply) {
    if (_sortStatusBySheet.containsKey(sheetId)) {
      _sortStatusBySheet[sheetId]!.toAlwaysApply = toAlwaysApply;
    }
  }

  void isAnalysing(String sheetId, bool isFindingBestSort, bool toSort) {
    _sortStatusBySheet[sheetId] = SortStatus(
      isFindingBestSort: isFindingBestSort,
      toAlwaysApply: toSort,
    );
  }

  void updateToFindValidSort(String sheetId, bool toFindValidSort) {
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

  bool bestSortFound(String sheetId, bool validSortFound) {
    if (!validSortFound || !_sortStatusBySheet[sheetId]!.isFindingBestSort) {
      _sortStatusBySheet.remove(sheetId);
      return true;
    }
    return false;
  }
}
