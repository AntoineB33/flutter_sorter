import 'dart:async';
import 'dart:math';
import 'package:isar/isar.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/history_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/selection_usecase.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:uuid/uuid.dart';

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

  @override
  void dispose() {
    _saveLastSelectionExecutor.dispose();
    selectionUsecase.removeListener(saveLastSelection);
    super.dispose();
  }

  void clearLastSelection() {
    selectionUsecase.clearLastSelection();
  }
}
