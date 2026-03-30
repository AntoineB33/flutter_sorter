import 'dart:math';

import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';

class SelectionCache {
  final Map<int, SelectionData> _lastSelections = {};

  Map<String, SelectionData> get lastSelections =>
      Map.unmodifiable(_lastSelections);

  bool containsSheetId(int sheetId) {
    return _lastSelections.containsKey(sheetId);
  }

  List<int> getSheetIds() {
    return _lastSelections.keys.toList();
  }

  List<CellPosition> getSelectedCells(int sheetId) {
    return _lastSelections[sheetId]?.selectedCells ?? [];
  }

  SelectionData getSelectionData(int sheetId) {
    return _lastSelections[sheetId] ??= SelectionData.empty();
  }

  void setLastSelections(
    Map<String, SelectionData> lastSelections,
    String currentSheetId,
  ) {
    SelectionData? currentSheetSelection = _lastSelections[currentSheetId];
    _lastSelections
      ..clear()
      ..addAll(lastSelections);
    if (currentSheetSelection != null) {
      _lastSelections[currentSheetId] = currentSheetSelection;
    }
  }

  void setSelectionData(int sheetId, SelectionData selectionData) {
    _lastSelections[sheetId] = selectionData;
  }

  void removeSelectionData(int sheetId) {
    _lastSelections.remove(sheetId);
  }
}
