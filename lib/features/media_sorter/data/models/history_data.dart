import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';

class HistoryData {
  List<UpdateData> updateHistories;
  int historyIndex;

  HistoryData({
    required this.updateHistories,
    required this.historyIndex,
  });
}