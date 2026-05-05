import 'package:trying_flutter/features/media_sorter/domain/models/history_type.dart';

abstract class HistoryRepository {
  bool moveInUpdateHistory(int sheetId, HistoryType historyType, int direction);

  void addSheetId(int sheetId);

  void commitHistory();
}
