import 'dart:math';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:flutter/foundation.dart';

class SelectionController extends ChangeNotifier {

  // --- getters ---
  List<Point<int>> get selectedCells => selection.selectedCells;
  Point<int> get primarySelectedCell => selection.primarySelectedCell;
  double get scrollOffsetX => selection.scrollOffsetX;
  double get scrollOffsetY => selection.scrollOffsetY;
  int get tableViewRows => selection.tableViewRows;
  int get tableViewCols => selection.tableViewCols;
  bool get editingMode => selection.editingMode;

  // --- setters ---
  set primarySelectedCell(Point<int> cell) {
    selection.primarySelectedCell = cell;
  }

  set scrollOffsetX(double offset) {
    selection.scrollOffsetX = offset;
  }

  set scrollOffsetY(double offset) {
    selection.scrollOffsetY = offset;
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

  bool isCellSelected(int row, int col) {
    return selectedCells.any((cell) => cell.x == row && cell.y == col);
  }

  bool isPrimarySelectedCell(int row, int col) {
    return row == primarySelectedCell.x && col == primarySelectedCell.y;
  }

  bool isCellEditing(int row, int col) =>
      editingMode &&
      primarySelectedCell.x == row &&
      primarySelectedCell.y == col;
}
