import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';

class SelectionCache  {
  Map<String, SelectionData> lastSelectionBySheet = {};
  final _updateDataController = StreamController<String>.broadcast();

  LoadedSheetsCache loadedSheetsDataStore;

  String get currentSheetId => loadedSheetsDataStore.currentSheetId;
  Stream<String> get updateData => _updateDataController.stream;
  SelectionData get selection =>
      lastSelectionBySheet[currentSheetId] ??=
          SelectionData.empty();
  Point<int> get primarySelectedCell => selection.primarySelectedCell;
  double get scrollOffsetX => selection.scrollOffsetX;
  double get scrollOffsetY => selection.scrollOffsetY;
  bool get editingMode => selection.editingMode;

  set scrollOffsetX(double value) {
    selection.scrollOffsetX = value;
    _updateDataController.add(currentSheetId);
  }

  set scrollOffsetY(double value) {
    selection.scrollOffsetY = value;
    _updateDataController.add(currentSheetId);
  }

  SelectionCache(this.loadedSheetsDataStore);

  void setEditingMode(bool isEditing) {
    SelectionData selection = lastSelectionBySheet[currentSheetId] ??=
        SelectionData.empty();
    selection.editingMode = isEditing;
    _updateDataController.add(currentSheetId);
  }

  void setNewSelectionData(String sheetId) {
    lastSelectionBySheet[sheetId] = SelectionData.empty();
    _updateDataController.add(sheetId);
  }

  void setSelectionData(String sheetId, SelectionData selectionData, bool save) {
    lastSelectionBySheet[sheetId] = selectionData;
    if (save) {
      _updateDataController.add(sheetId);
    }
  }

  void setLastSelectionBySheet(Map<String, SelectionData> lastSelectionBySheet, bool save) {
    this.lastSelectionBySheet = lastSelectionBySheet;
    if (save) {
      _updateDataController.add(currentSheetId);
    }
  }
}
