import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';

class SelectionCache {
  final Map<String, SelectionData> _lastSelections = {};

  Map<String, SelectionData> get lastSelections => Map.unmodifiable(_lastSelections);

  bool containsSheetId(String sheetId) {
    return _lastSelections.containsKey(sheetId);
  }

  List<String> getSheetIds() {
    return _lastSelections.keys.toList();
  }

  List<Point<int>> getSelectedCells(String sheetId) {
    return _lastSelections[sheetId]?.selectedCells ?? [];
  }

  SelectionData getSelectionData(String sheetId) {
    return _lastSelections[sheetId] ??= SelectionData.empty();
  }

  void setLastSelections(Map<String, SelectionData> lastSelections, String currentSheetId, bool lastSelectionLoaded) {
    SelectionData currentSheetSelection = _lastSelections[currentSheetId]!;
    _lastSelections
      ..clear()
      ..addAll(lastSelections);
    if (lastSelectionLoaded) {
      _lastSelections[currentSheetId] = currentSheetSelection;
    }
  }

  void setSelectionData(
    String sheetId,
    SelectionData selectionData,
  ) {
    _lastSelections[sheetId] = selectionData;
  }

  void removeSelectionData(String sheetId) {
    _lastSelections.remove(sheetId);
  }
}
