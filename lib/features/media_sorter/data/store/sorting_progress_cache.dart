import 'package:trying_flutter/features/media_sorter/data/models/sort_progress_data.dart';

class SortProgressCache {
  final Map<int, SortProgressData> _dataBySheet = {};

  bool isValidSortImpossible(int sheetId) {
    if (!_dataBySheet.containsKey(sheetId)) {
      return false;
    }
    return !_dataBySheet[sheetId]!.hasMoreToExplore() &&
        _dataBySheet[sheetId]!.bestDistFound.isEmpty;
  }

  SortProgressData getSortProgressData(int sheetId) {
    return _dataBySheet[sheetId]!;
  }

  void update(int sheetId, SortProgressData newProgressData) {
    _dataBySheet[sheetId] = newProgressData;
  }
}
