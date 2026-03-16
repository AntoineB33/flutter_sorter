import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';


class SortProgressCache {
  final Map<String, SortProgressData> _dataBySheet = {};

  bool isValidSortImpossible(String sheetId) {
    if (!_dataBySheet.containsKey(sheetId)) {
      return false;
    }
    return _dataBySheet[sheetId]!.cursors[0] == _dataBySheet[sheetId]!.possibleIntsById[0].length && _dataBySheet[sheetId]!.bestDistFound.isEmpty;
  }

  SortProgressData getSortProgressData(String sheetId) {
    return _dataBySheet[sheetId]!;
  }

  void update(String sheetId, SortProgressData newProgressData) {
    _dataBySheet[sheetId] = newProgressData;
  }
}
