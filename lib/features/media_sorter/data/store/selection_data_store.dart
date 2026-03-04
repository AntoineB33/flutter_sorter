import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';

class SelectionDataStore extends ChangeNotifier {
  Map<String, SelectionData> lastSelectionBySheet = {};

  LoadedSheetsCache loadedSheetsDataStore;

  SelectionData get selection =>
      lastSelectionBySheet[loadedSheetsDataStore.currentSheetId] ??=
          SelectionData.empty();
  Point<int> get primarySelectedCell => selection.primarySelectedCell;
  double get scrollOffsetX => selection.scrollOffsetX;
  double get scrollOffsetY => selection.scrollOffsetY;
  bool get editingMode => selection.editingMode;

  set scrollOffsetX(double value) {
    selection.scrollOffsetX = value;
    notifyListeners();
  }

  set scrollOffsetY(double value) {
    selection.scrollOffsetY = value;
    notifyListeners();
  }

  SelectionDataStore(this.loadedSheetsDataStore);

  void setEditingMode(bool isEditing) {
    String currentSheetName = loadedSheetsDataStore.currentSheetId;
    SelectionData selection = lastSelectionBySheet[currentSheetName] ??=
        SelectionData.empty();
    selection.editingMode = isEditing;
    notifyListeners();
  }
}
