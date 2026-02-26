import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';

class SelectionDataStore extends ChangeNotifier {
  Map<String, SelectionData> lastSelectionBySheet = {};

  LoadedSheetsDataStore loadedSheetsDataStore;

  SelectionData get selection =>
      lastSelectionBySheet[loadedSheetsDataStore.currentSheetId] ??=
          SelectionData.empty();
  Point<int> get primarySelectedCell => selection.primarySelectedCell;
  double get scrollOffsetX => selection.scrollOffsetX;
  double get scrollOffsetY => selection.scrollOffsetY;
  int get tableViewRows => selection.tableViewRows;
  int get tableViewCols => selection.tableViewCols;
  bool get editingMode => selection.editingMode;

  set scrollOffsetX(double value) {
    selection.scrollOffsetX = value;
  }

  set scrollOffsetY(double value) {
    selection.scrollOffsetY = value;
  }

  set tableViewRows(int value) {
    selection.tableViewRows = value;
  }

  set tableViewCols(int value) {
    selection.tableViewCols = value;
  }

  SelectionDataStore(this.loadedSheetsDataStore);

  SelectionData getSelection(String sheetName) {
    return lastSelectionBySheet[sheetName] ??= SelectionData.empty();
  }

  void saveSelection() {
    notifyListeners();
  }

  void setEditingMode(bool isEditing) {
    String currentSheetName = loadedSheetsDataStore.currentSheetId;
    SelectionData selection = lastSelectionBySheet[currentSheetName] ??=
        SelectionData.empty();
    selection.editingMode = isEditing;
    notifyListeners();
  }
}
