import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';

enum SortStatus {
  calculatingResult,
  findingValidSort,
  findingBestSort,
  sortWhileFindingBestSort,
  none,
}

class SortStatusCache extends ChangeNotifier {
  final ManageWaitingTasks<void> _saveSortStatusExecutor =
      ManageWaitingTasks<void>(
        Duration(milliseconds: 1000),
      );
  final Map<String, SortStatus> _sortStatusBySheet = {};
  bool _isNotifyScheduled = false;

  final LoadedSheetsCache loadedSheetsDataStore;
  
  void scheduleNotifyListeners() {
    if (!_isNotifyScheduled) {
      _isNotifyScheduled = true;
      scheduleMicrotask(() {
        notifyListeners();
        _isNotifyScheduled = false;
      });
    }
  }

  SortStatusCache(this.loadedSheetsDataStore);

  ManageWaitingTasks<void> get saveSortStatusExecutor => _saveSortStatusExecutor;
  Map<String, SortStatus> get sortStatusBySheet => _sortStatusBySheet;

  bool containsSheet(String sheetName) {
    return _sortStatusBySheet.containsKey(sheetName);
  }

  SortStatus getSortStatus(String sheetName) {
    return _sortStatusBySheet[sheetName] ?? SortStatus.none;
  }

  bool isCalculatingResult(String sheetName) {
    return getSortStatus(sheetName) == SortStatus.calculatingResult;
  }

  bool isFindingBestSort(String sheetName) {
    return getSortStatus(sheetName) == SortStatus.findingBestSort;
  }

  void calculatingResult(String sheetName) {
    _sortStatusBySheet[sheetName] = SortStatus.calculatingResult;
    scheduleNotifyListeners();
  }

  void updateToFindValidSort(String sheetName, bool toFindValidSort) {
    if (toFindValidSort) {
      _sortStatusBySheet[sheetName] = SortStatus.findingValidSort;
    } else {
      removeSortStatus(sheetName);
    }
    scheduleNotifyListeners();
  }

  void loadAllSortStatus(Map<String, SortStatus> statuses) {
    _sortStatusBySheet
      ..clear()
      ..addAll(statuses);
  }

  void removeSortStatus(String sheetId) {
    if (_sortStatusBySheet.containsKey(sheetId)) {
      _sortStatusBySheet.remove(sheetId);
      scheduleNotifyListeners();
    }
  }
}
