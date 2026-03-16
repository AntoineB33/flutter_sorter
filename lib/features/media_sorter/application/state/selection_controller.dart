import 'dart:async';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/history_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/selection_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort_usecase.dart';

class SelectionController extends ChangeNotifier {
  final SelectionUsecase selectionUsecase;
  final SortUsecase sortUsecase;
  final HistoryUsecase historyUsecase;
  bool editingMode = false;

  SelectionController(
    this.selectionUsecase,
    this.sortUsecase,
    this.historyUsecase,
  );

  double getScrollOffsetX(String sheetId) {
    return selectionUsecase.getScrollOffsetX(sheetId);
  }

  double getScrollOffsetY(String sheetId) {
    return selectionUsecase.getScrollOffsetY(sheetId);
  }

  SelectionData getSelectionData(String sheetId) {
    return selectionUsecase.getSelectionData(sheetId);
  }

  Future<void> saveLastSelection() async {
    selectionUsecase.saveLastSelection();
  }

  bool isCellSelected(SelectionData selection, int row, int col) {
    return selection.selectedCells.any(
      (cell) => cell.x == row && cell.y == col,
    );
  }

  bool isPrimarySelectedCell(SelectionData selection, int row, int col) {
    return row == selection.primarySelectedCell.x &&
        col == selection.primarySelectedCell.y;
  }

  bool isCellEditing(SelectionData selection, int row, int col) =>
      editingMode &&
      selection.primarySelectedCell.x == row &&
      selection.primarySelectedCell.y == col;

  Future<bool> loadLastSelection() async {
    bool success = await selectionUsecase.loadLastSelection();
    notifyListeners();
    return success;
  }

  void setPrimarySelection(
    int row,
    int col,
    bool keepSelection, {
    bool scrollTo = true,
  }) {
    selectionUsecase.setPrimarySelection(row, col, keepSelection);
    notifyListeners();
  }

  void sheetSwitched() {
    selectionUsecase.sheetSwitch();
  }

  void stopEditing(String prevValue, bool updateHistory) {
    if (updateHistory) {
      historyUsecase.stopEditing(prevValue);
    }
    editingMode = false;
    notifyListeners();
  }

  bool isSorting() {
    return sortUsecase.isSorting();
  }

  bool startEditing() {
    if (isSorting()) {
      return false;
    }
    editingMode = true;
    saveLastSelection();
    notifyListeners();
    return true;
  }

  void selectAll() {
    selectionUsecase.selectAll();
  }

  void clearLastSelection() {
    selectionUsecase.clearLastSelection();
  }
}
