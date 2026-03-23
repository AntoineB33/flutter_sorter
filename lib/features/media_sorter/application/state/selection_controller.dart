import 'dart:async';
import 'dart:math';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/history_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/selection_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/workbook_usecase.dart';

class SelectionController extends ChangeNotifier {
  final SelectionUsecase selectionUsecase;
  final SortUsecase sortUsecase;
  final HistoryUsecase historyUsecase;
  final WorkbookUsecase workbookUsecase;
  final SheetDataUsecase sheetDataUsecase;
  
  bool editingMode = false;

  String? get currentSheetId => workbookUsecase.currentSheetId;
  Point<int> get primarySelectedCell => selectionUsecase.primarySelectedCell;

  SelectionController(
    this.selectionUsecase,
    this.sortUsecase,
    this.historyUsecase,
    this.workbookUsecase,
    this.sheetDataUsecase,
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

  bool isCellSelected(int row, int col) {
    return currentSheetId != null && selectionUsecase.getSelectionData(currentSheetId!).selectedCells.any(
      (cell) => cell.x == row && cell.y == col,
    );
  }

  bool isPrimarySelectedCell(int row, int col) {
    return row == primarySelectedCell.x &&
        col == primarySelectedCell.y;
  }

  bool isCellEditing(int row, int col) =>
      editingMode &&
      primarySelectedCell.x == row &&
      primarySelectedCell.y == col;

  Future<bool> loadLastSelection() async {
    bool success = await selectionUsecase.loadLastSelection();
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

  void stopEditing(Map<String, UpdateData> updates, bool escape) {
    historyUsecase.stopEditing(updates, escape);
    editingMode = false;
    notifyListeners();
  }

  bool isSorting() {
    return sortUsecase.isSorting();
  }

  bool startEditing() {
    if (isSorting() || currentSheetId == null) {
      return false;
    }
    previousEditingValue = sheetDataUsecase.getCellContent(
      primarySelectedCell.x,
      primarySelectedCell.y,
      currentSheetId!,
    );
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
