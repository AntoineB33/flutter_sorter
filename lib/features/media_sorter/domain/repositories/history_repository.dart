import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';

abstract class HistoryRepository {
  void moveInUpdateHistory(HistoryType historyType, int direction);

  List<SyncRequestWithoutHist> commitHistory(
    List<SyncRequestWithHist> updates,
    int sheetId,
    HistoryType historyType,
    bool sameHistIdFromLast,
  );

  void stopEditing(bool escape);

  void addSheetId(int sheetId);
}
