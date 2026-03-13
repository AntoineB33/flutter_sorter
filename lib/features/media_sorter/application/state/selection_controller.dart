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
import 'package:trying_flutter/features/media_sorter/domain/usecases/selection_usecase.dart';
import 'package:trying_flutter/features/media_sorter/data/services/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sort_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/application/state/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/history_service.dart';
import 'package:trying_flutter/features/media_sorter/data/store/analysis_result_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/loaded_sheets_cache.dart';
import 'package:trying_flutter/features/media_sorter/data/store/selection_cache.dart';
import 'package:uuid/uuid.dart';

class SelectionController extends ChangeNotifier {
  final SelectionUsecase selectionUsecase;
  final SortUsecase sortUsecase;
  StreamSubscription? _updateData;

  SelectionController(this.selectionUsecase, this.sortUsecase) {
    _updateData = selectionUsecase.updateData.listen((sheetId) {
      selectionUsecase.saveSelection();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _updateData?.cancel();
    super.dispose();
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
      selection.editingMode &&
      selection.primarySelectedCell.x == row &&
      selection.primarySelectedCell.y == col;

  void setPrimarySelection(
    int row,
    int col,
    bool keepSelection, {
    bool scrollTo = true,
  }) {
    selectionUsecase.setPrimarySelection(row, col, keepSelection);
    notifyListeners();
  }

  void stopEditing(String prevValue, bool updateHistory) {
    selectionUsecase.stopEditing(prevValue, updateHistory);
  }

  bool isSorting() {
    return sortUsecase.isSorting();
  }

  bool startEditing() {
    if (isSorting()) {
      return false;
    }
    selection.previousContent = loadedSheetsDataStore.getCellContent(
      selection.primarySelectedCell.x,
      selection.primarySelectedCell.y,
    );
    selection.editingMode = true;
    saveLastSelection();
    notifyListeners();
    return true;
  }

  void selectAll() {
    selection.selectedCells.clear();
    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        selection.selectedCells.add(Point(r, c));
      }
    }
    setPrimarySelection(currentSheetName, 0, 0, true);
  }

  @override
  void dispose() {
    _saveLastSelectionExecutor.dispose();
    selectionUsecase.removeListener(saveLastSelection);
    super.dispose();
  }

  void setPrimarySelection(
    int row,
    int col,
    bool keepSelection, {
    bool scrollTo = true,
  }) {
    selectionController.setPrimarySelection(
      row,
      col,
      keepSelection,
      scrollTo: scrollTo,
    );

    treeController.updateMentionsContext(row, col);
  }

  void clearLastSelection() {
    selectionUsecase.clearLastSelection();
  }
}
