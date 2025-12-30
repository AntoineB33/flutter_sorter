import 'dart:math';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_controller.dart';

class SelectionManager {
  final SpreadsheetController _controller;
  Point<int> selectionStart = const Point(0, 0);
  Point<int> selectionEnd = const Point(0, 0);

  SelectionManager(this._controller);
  
  void checkSelectChange(
    Point<int> newSelectionStart,
    Point<int> newSelectionEnd,
  ) {
    if (selectionStart != newSelectionStart ||
        selectionEnd != newSelectionEnd) {
      selectionStart = newSelectionStart;
      selectionEnd = newSelectionEnd;
      _controller.saveAndCalculate(calculate: false);
      _controller.saveLastSelectedCell(selectionStart);
      _controller.mentionsRoot.rowId = selectionStart.x;
      _controller.mentionsRoot.colId = selectionStart.y;
      _controller.populateTree([_controller.mentionsRoot]);
      _controller.notify();
    }
  }

  void selectCell(int row, int col) {
    var newSelectionStart = Point(row, col);
    var newSelectionEnd = Point(row, col);
    checkSelectChange(newSelectionStart, newSelectionEnd);
  }

  void selectRange(int startRow, int startCol, int endRow, int endCol) {
    var newSelectionStart = Point(startRow, startCol);
    var newSelectionEnd = Point(endRow, endCol);
    checkSelectChange(newSelectionStart, newSelectionEnd);
  }

  void selectAll() {
    selectRange(0, 0, _controller.rowCount - 1, _controller.colCount - 1);
  }
}