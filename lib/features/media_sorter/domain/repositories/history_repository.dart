import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class HistoryRepository {
  UpdateData? moveInUpdateHistory(int direction);
  void commitHistory(Map<String, UpdateUnit> updates, String sheetId, bool isFromEditing);
  void stopEditing(String prevValue);
}