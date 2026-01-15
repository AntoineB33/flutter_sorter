import 'dart:math';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_controller.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';

class SelectionManager {
  final SpreadsheetController _controller;
  SelectionModel selection = SelectionModel.empty();

  Point<int> get primarySelectedCell => selection.primarySelectedCell;
  List<Point<int>> get selectedCells => selection.selectedCells;

  SelectionManager(this._controller);

  void setPrimarySelection(int row, int col, bool keepSelection, bool updateMentions, {bool scrollTo = true}) {
    if (!keepSelection) {
      selectedCells.clear();
    }
    selection.primarySelectedCell = Point(row, col);
    _controller.saveLastSelection(_controller.selection);

    // Update Mentions
    if (updateMentions) {
      _controller.mentionsRoot.newChildren = null;
      _controller.mentionsRoot.rowId = row;
      _controller.mentionsRoot.colId = col;
      _controller.populateTree([_controller.mentionsRoot]);
    }

    // Request scroll to visible
    if (scrollTo) {
      _controller.triggerScrollTo(row, col);
    }
    _controller.notify();
  }

  void keepOnlyPrim() {
    selectedCells.clear();
    _controller.saveLastSelection(selection);
    _controller.notify();
  }

  void selectAll() {
    selectedCells.clear();
    for (int r = 0; r < _controller.rowCount; r++) {
      for (int c = 0; c < _controller.colCount; c++) {
        selectedCells.add(Point(r, c));
      }
    }
    setPrimarySelection(0, 0, true, true);
  }
}
