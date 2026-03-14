import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';


class SortProgressCache {
  final Map<String, SortProgressData> _dataBySheet = {};

  bool isValidSortImpossible(String sheetId) {
    return _dataBySheet.containsKey(sheetId) && _dataBySheet[sheetId]!.cursors.isEmpty;
  }

  SortProgressData getSortProgressData(String sheetId) {
    return _dataBySheet[sheetId]!;
  }

  void update(String sheetId, SortProgressData newProgressData) {
    _dataBySheet[sheetId] = newProgressData;
  }
}
