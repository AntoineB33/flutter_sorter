import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';

class SelectionCache {
  final Map<int, HistoryData> _selections = {};

  SheetDataTablesCompanion getSelectionState(int sheetId) {
    return getSelectionData(sheetId).updateHistories[getSelectionData(
      sheetId,
    ).historyIndex].updates.first.companionWrapper
        as SheetDataTablesCompanion;
  }

  int primarySelectedCellX(int sheetId) {
    return getSelectionState(sheetId)
        .primarySelectionX.value;
  }

  int primarySelectedCellY(int sheetId) {
    return getSelectionState(sheetId)
        .primarySelectionY.value;
  }

  Map<String, HistoryData> get selections => Map.unmodifiable(_selections);

  HistoryData getSelectionData(int sheetId) {
    if (!_selections.containsKey(sheetId)) {
      setSelectionData(sheetId, HistoryData.empty());
    }
    return _selections[sheetId]!;
  }

  void setSelectionData(int sheetId, HistoryData selectionData) {
    _selections[sheetId] = selectionData;
  }

}
