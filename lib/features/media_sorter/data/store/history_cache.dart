import 'package:trying_flutter/features/media_sorter/domain/entities/history_data.dart';

class HistoryCache {
  final Map<int, HistoryData> _cache = {};

  HistoryData? operator [](int sheetId) => _cache[sheetId];

  void operator []=(int sheetId, HistoryData historyData) {
    _cache[sheetId] = historyData;
  }

  int getPrimarySelectedCellX(int sheetId) {
    return _cache[sheetId]!.primSelHistory[_cache[sheetId]!.primSelHistoryId].rowId;
  }

  int getPrimarySelectedCellY(int sheetId) {
    return _cache[sheetId]!.primSelHistory[_cache[sheetId]!.primSelHistoryId].colId;
  }
  
}
