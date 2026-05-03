import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';

abstract class HistoryRepository {
  void moveInUpdateHistory(int sheetId, HistoryType historyType, int direction);

  void scheduleCommit();

  void addSheetId(int sheetId);
}
