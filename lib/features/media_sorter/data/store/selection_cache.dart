import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';

class SelectionCache {
  final Map<int, SelectionData> _selections = {};

  SelectionState getSelectionState(int sheetId) {
    return getSelectionData(sheetId).selectionStates[getSelectionData(
      sheetId,
    ).primSelHistoryId];
  }

  int primarySelectedCellX(int sheetId) {
    return getSelectionState(sheetId).primarySelection.rowId;
  }

  int primarySelectedCellY(int sheetId) {
    return getSelectionState(sheetId).primarySelection.colId;
  }

  Map<String, SelectionData> get selections => Map.unmodifiable(_selections);

  SelectionData getSelectionData(int sheetId) {
    return _selections[sheetId] ??= SelectionData.empty();
  }

  void setSelectionData(int sheetId, SelectionData selectionData) {
    _selections[sheetId] = selectionData;
  }
}
