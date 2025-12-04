// lib/src/features/media_sorter2/presentation/controllers/spreadsheet_selection_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages which cells are currently visually selected.
/// State is a Set of unique keys (e.g., "0:1", "4:5").
class SpreadsheetSelectionController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {};
  }

  /// Selects a single cell, clearing previous selections.
  void selectCell(int row, int col) {
    state = {'$row:$col'};
  }

  /// Selects all cells based on grid dimensions.
  void selectAll(int totalRows, int totalCols) {
    final allKeys = <String>{};
    for (var r = 0; r < totalRows; r++) {
      for (var c = 0; c < totalCols; c++) {
        allKeys.add('$r:$c');
      }
    }
    state = allKeys;
  }
  
  /// Clears selection (optional utility)
  void clear() {
    state = {};
  }
}

final spreadsheetSelectionProvider =
    NotifierProvider<SpreadsheetSelectionController, Set<String>>(
        SpreadsheetSelectionController.new);