import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';

class CurrentChangeList {
  int sheetId = -1;
  List<SyncRequestWithoutHist> changeList = [];
  List<SyncRequestWithHist> changeListWithHist = [];

  void clear() {
    sheetId = -1;
    changeList.clear();
    changeListWithHist.clear();
  }
}