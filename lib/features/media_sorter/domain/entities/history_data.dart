import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

class HistoryData {
  List<UpdateData> updateHistories;
  int historyIndex;
  List<CellPosition> primSelHistory;
  int primSelHistoryId;

  HistoryData({
    required this.updateHistories,
    required this.historyIndex,
    required this.primSelHistory,
    required this.primSelHistoryId,

  });
}