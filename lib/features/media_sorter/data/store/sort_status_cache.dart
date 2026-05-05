import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/sort_status.dart';

class SortStatusCache {
  final Map<int, SortStatus> _sortStatusBySheet = {};

  final LoadedSheetsCache loadedSheetsDataStore;

  SortStatusCache(this.loadedSheetsDataStore);

  Map<int, SortStatus> get sortStatusBySheet => _sortStatusBySheet;

  bool containsSheet(int sheetId) {
    return _sortStatusBySheet.containsKey(sheetId);
  }

  bool getToApplyOnce(int sheetId) {
    return _sortStatusBySheet[sheetId]?.toApplyNextBestSort ?? false;
  }

  bool getAnalysisDone(int sheetId) {
    return _sortStatusBySheet[sheetId]?.analysisDone ?? false;
  }

  void setToApplyOnce(int sheetId, bool value) {
    _sortStatusBySheet[sheetId] ??= SortStatus.initial();
    _sortStatusBySheet[sheetId]!.copyWith(toApplyNextBestSort: value);
  }

  void setAnalysisDone(int sheetId, bool analysisDone) {
    _sortStatusBySheet[sheetId] ??= SortStatus.initial();
    _sortStatusBySheet[sheetId]!.copyWith(analysisDone: analysisDone);
  }

  void updateSortStatus(int sheetId, SortStatus newStatus) {
    _sortStatusBySheet[sheetId] = newStatus;
  }

  void setAllSortStatus(Map<int, SortStatus> statuses) {
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
