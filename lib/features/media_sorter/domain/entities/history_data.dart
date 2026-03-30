import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

class HistoryData {
  List<UpdateData> updateHistories;
  List<CellPosition> selectionHistory;
  int historyIndex;

  HistoryData({
    required this.updateHistories,
    required this.selectionHistory,
    required this.historyIndex,
  });
}