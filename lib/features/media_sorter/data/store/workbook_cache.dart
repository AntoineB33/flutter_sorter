
class WorkbookCache {
  final List<int> _recentSheetIds = [];
  int get currentSheetId => _recentSheetIds.first;

  bool containsSheetId(int sheetId) {
    return _recentSheetIds.contains(sheetId);
  }
  
  List<int> getRecentSheetIds() {
    return _recentSheetIds;
  }

  void setRecentIds(List<int> recentIds) {
    _recentSheetIds
      ..clear()
      ..addAll(recentIds);
  }

  void removeSheetId(int sheetId) {
    _recentSheetIds.remove(sheetId);
  }

  void addSheetId(int sheetId, int index) {
    _recentSheetIds.insert(index, sheetId);
  }
}