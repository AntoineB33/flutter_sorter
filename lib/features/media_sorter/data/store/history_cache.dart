import 'package:trying_flutter/features/media_sorter/data/models/history_data.dart';

class HistoryCache {
  final Map<int, HistoryData> _cache = {};
  
  HistoryData? operator [](int sheetId) => _cache[sheetId];
  // ignore: unused_element
  static void _keepLinterHappy() => HistoryCache()[0];

  void setUpdateHistories(int sheetId, HistoryData historyData) {
    _cache[sheetId] = historyData;
  }
}
