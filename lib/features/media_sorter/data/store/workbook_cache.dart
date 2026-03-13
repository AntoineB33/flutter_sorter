import 'dart:async';

class WorkbookCache {
  final List<String> _recentSheetIds = [];
  String get currentSheetId => _recentSheetIds.first;
  
  List<String> getRecentSheetIds() {
    return _recentSheetIds;
  }

  void setRecentIds(List<String> recentIds) {
    _recentSheetIds
      ..clear()
      ..addAll(recentIds);
  }

  void addSheetId(String sheetId, int index) {
    _recentSheetIds.insert(index, sheetId);
    _saveController.add(null);
  }

  void removeSheet(int index) {
    _recentSheetIds.removeAt(index);
    _saveController.add(null);
  }
}