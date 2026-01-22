import 'dart:math';
import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';

class SelectionController {
  // --- states ---
  SelectionModel selection = SelectionModel.empty();

  // --- getters ---
  Point<int> get primarySelectedCell => selection.primarySelectedCell;
  List<Point<int>> get selectedCells => selection.selectedCells;
  int get tableViewRows => selection.tableViewRows;
  int get tableViewCols => selection.tableViewCols;
  bool get editingMode => selection.editingMode;

  // --- setters ---
  set primarySelectedCell(Point<int> cell) {
    selection.primarySelectedCell = cell;
  }
  set tableViewRows(int rows) {
    selection.tableViewRows = rows;
  }
  set tableViewCols(int cols) {
    selection.tableViewCols = cols;
  }
  set previousContent(String content) {
    selection.previousContent = content;
  }
  set editingMode(bool isEditing) {
    selection.editingMode = isEditing;
  }

  SelectionController();
}
