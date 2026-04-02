import 'package:trying_flutter/features/media_sorter/domain/entities/history_data.dart';

class HistoryCache {
  final Map<int, HistoryData> _cache = {};
  
  HistoryData? operator [](int sheetId) => _cache[sheetId];

  void setUpdateHistories(int sheetId, HistoryData historyData) {
    _cache[sheetId] = historyData;
  }
}
