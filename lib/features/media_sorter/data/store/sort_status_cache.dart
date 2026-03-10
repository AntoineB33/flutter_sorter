import 'dart:async';

import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';

class SortStatusCache {
  final Map<String, SortStatus> _sortStatusBySheet = {};
  final _updateDataController = StreamController<void>.broadcast();

  final LoadedSheetsCache loadedSheetsDataStore;

  Stream<void> get updateData => _updateDataController.stream;

  SortStatusCache(this.loadedSheetsDataStore);

  Map<String, SortStatus> get sortStatusBySheet => _sortStatusBySheet;

  List<String> getSheetIds() {
    return _sortStatusBySheet.keys.toList();
  }

  bool isAnalysisDone(String sheetId) {
    return _sortStatusBySheet[sheetId]?.analysisDone ?? false;
  }

  bool isFindingBestSort(String sheetId) {
    return _sortStatusBySheet[sheetId]?.isFindingBestSort ?? false;
  }

  bool toSort(String sheetId) {
    return _sortStatusBySheet[sheetId]?.toSort ?? false;
  }

  void isAnalysing(String sheetId, bool isFindingBestSort, bool toSort) {
    _sortStatusBySheet[sheetId] = SortStatus(
      isFindingBestSort: isFindingBestSort,
      toSort: toSort,
    );
  }

  void updateToFindValidSort(String sheetId, bool toFindValidSort) {
    if (toFindValidSort) {
      _sortStatusBySheet[sheetId]!.analysisDone = true;
    } else {
      removeSortStatus(sheetId);
    }
    _updateDataController.add(null);
  }

  void setSortStatus(Map<String, SortStatus> statuses) {
    _sortStatusBySheet
      ..clear()
      ..addAll(statuses);
  }

  void removeSortStatus(String sheetId) {
    if (_sortStatusBySheet.containsKey(sheetId)) {
      _sortStatusBySheet.remove(sheetId);
      _updateDataController.add(null);
    }
  }

  void bestSortFound(String sheetId, bool validSortFound) {
    if (!validSortFound || !_sortStatusBySheet[sheetId]!.isFindingBestSort) {
      _sortStatusBySheet.remove(sheetId);
      _updateDataController.add(null);
    }
  }
}
