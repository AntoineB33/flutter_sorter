

import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';

class SortProgressCache {
  final Map<String, SortProgressData> _dataBySheet = {};

  SortProgressData getSortProgressData(String sheetId) {
    return _dataBySheet[sheetId] ??= SortProgressData.empty();
  }

  void updateSortProgressData(String sheetId, SortProgressData data) {
    _dataBySheet[sheetId] = data;
  }
}