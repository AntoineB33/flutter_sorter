import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';

abstract class HistoryRepository {
  void moveInUpdateHistory(HistoryType historyType, int direction);

  void commitHistory(
    int sheetId,
    bool sameHistIdFromLast,
  );

  void addSheetId(int sheetId);
}
