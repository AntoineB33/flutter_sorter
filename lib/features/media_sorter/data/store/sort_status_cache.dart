import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';

class SortStatusCache extends ChangeNotifier {
  final Map<String, String> _sortStatusBySheet = {};

  static String calculatingResultKey = "calculatingResult";
  static String findingValidSortKey = "findingValidSort";
  static String findingBestSortKey = "findingBestSort";
  static String sortWhileFindingBestSortKey = "sortWhileFindingBestSort";

  final LoadedSheetsCache loadedSheetsDataStore;

  Map<String, String> get sortStatusBySheet =>
      Map.unmodifiable(_sortStatusBySheet);
  String get currentSortStatus =>
      getSortStatus(loadedSheetsDataStore.currentSheetId);

  SortStatusCache(this.loadedSheetsDataStore);

  bool containsSheet(String sheetName) {
    return _sortStatusBySheet.containsKey(sheetName);
  }

  String getSortStatus(String sheetName) {
    return _sortStatusBySheet[sheetName] ??= "";
  }

  bool isCalculatingResult(String sheetName) {
    return getSortStatus(sheetName) == calculatingResultKey;
  }

  void update(String sheetName, bool toFindValidSort) {
    if (toFindValidSort) {
      setSortStatus(sheetName, findingValidSortKey);
    } else {
      _removeSortStatus(sheetName);
    }
    notifyListeners();
  }

  void loadAllSortStatus(Map<String, String> statuses) {
    _sortStatusBySheet
      ..clear()
      ..addAll(statuses);
  }

  void setSortStatus(String sheetName, String sortStatus) {
    _sortStatusBySheet[sheetName] = sortStatus;
    notifyListeners();
  }

  void _removeSortStatus(String sheetName) {
    if (_sortStatusBySheet.containsKey(sheetName)) {
      _sortStatusBySheet.remove(sheetName);
      notifyListeners();
    }
  }
}
