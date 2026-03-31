import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class HistoryRepository {
  UpdateData? moveInUpdateHistory(int direction);
  void commitHistory(
    Map<String, UpdateUnit> updates,
    int sheetId,
    bool isFromEditing,
  );
  void stopEditing(bool escape, {Map<String, UpdateUnit>? updates});
  UpdateUnit newPrimarySelection(int rowId, int colId);
}
