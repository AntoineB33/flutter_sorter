import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';


class SortProgressCache {
  final Map<String, SortProgressData> _dataBySheet = {};

  SortProgressData getSortProgressData(String sheetId) {
    return _dataBySheet[sheetId]!;
  }

  void update(String sheetId, SortProgressData newProgressData) {
    _dataBySheet[sheetId] = newProgressData;
  }
}
