import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';

class HistoryData {
  List<List<SyncRequest>> updateHistories;
  int historyIndex;

  HistoryData({
    required this.updateHistories,
    required this.historyIndex,
  });

  factory HistoryData.empty() {
    return HistoryData(
      updateHistories: [],
      historyIndex: -1,
    );
  }
}