import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';

class SelectionCache {
  final Map<int, HistoryData> _selections = {};

  HistoryData? operator [](int sheetId) => _selections[sheetId];
  // ignore: unused_element
  static void _keepLinterHappy() => SelectionCache()[0];

  HistoryUnit getSelectionState(int sheetId) {
    return getSelectionData(sheetId).updateHistories[getSelectionData(
      sheetId,
    ).historyIndex];
  }

  SheetDataTablesCompanion getCompanion(int sheetId) {
    return (getSelectionState(sheetId).changeSet.first.companionWrapper
            as SheetDataWrapper)
        .companion;
  }

  int primarySelectedCellX(int sheetId) {
    return getCompanion(sheetId)
        .primarySelectionX.value;
  }

  int primarySelectedCellY(int sheetId) {
    return getCompanion(sheetId)
        .primarySelectionY.value;
  }

  Map<String, HistoryData> get selections => Map.unmodifiable(_selections);

  HistoryData getSelectionData(int sheetId) {
    return _selections[sheetId] ??= HistoryData.empty();
  }

  void setSelectionData(int sheetId, HistoryData selectionData) {
    _selections[sheetId] = selectionData;
  }
}
