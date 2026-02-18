import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';

class SortStatusDataStore extends ChangeNotifier {
  final Map<String, SortStatus> _sortStatusBySheet = {};

  Map<String, SortStatus> get sortStatusBySheet => Map.unmodifiable(_sortStatusBySheet);

  SortStatus getSortStatus(String sheetName) {
    return _sortStatusBySheet[sheetName] ??= SortStatus.empty();
  }

  void loadAllSortStatus(Map<String, SortStatus> statuses) {
    _sortStatusBySheet..clear()
      ..addAll(statuses);
  }

  void setSortStatus(String sheetName, SortStatus sortStatus) {
    _sortStatusBySheet[sheetName] = sortStatus;
    notifyListeners();
  }

  void updateSortStatus(String sheetName, void Function(SortStatus status) updater) {
    final status = getSortStatus(sheetName);
    updater(status);
    notifyListeners();
  }

  void removeSortStatus(String sheetName) {
    if (_sortStatusBySheet.containsKey(sheetName)) {
      _sortStatusBySheet.remove(sheetName);
      notifyListeners();
    }
  }
}