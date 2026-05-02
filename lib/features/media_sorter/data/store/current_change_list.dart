import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';

class CurrentChangeList {
  int sheetId = -1;
  List<SyncRequestWithHist> changeListWithHist = [];

  void clear() {
    changeListWithHist.clear();
  }
}
