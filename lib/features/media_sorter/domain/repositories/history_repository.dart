import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';

abstract class HistoryRepository {
  void moveInUpdateHistory(HistoryType historyType, int direction);

  void commitHistory(
    int sheetId,
    HistoryType historyType,
    bool sameHistIdFromLast,
  );

  void addSheetId(int sheetId);
}
