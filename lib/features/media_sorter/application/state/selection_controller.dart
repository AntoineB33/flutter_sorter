import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
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

  int get currentSheetId => workbookUsecase.currentSheetId;
  int get primarySelectedCellX => selectionUsecase.primarySelectedCellX;
  int get primarySelectedCellY => selectionUsecase.primarySelectedCellY;
  Set<CellPosition> get selectedCells =>
      selectionUsecase.selectedCells;

  SelectionController(
    this.selectionUsecase,
    this.sortUsecase,
    this.historyUsecase,
    this.workbookUsecase,
    this.sheetDataUsecase,
  );

  bool isCellSelected(int row, int col) {
    return selectedCells.contains(CellPosition(row, col));
  }

  bool isPrimarySelectedCell(int row, int col) {
    return row == primarySelectedCellX && col == primarySelectedCellY;
  }

  bool isCellEditing(int row, int col) =>
      editingMode && primarySelectedCellX == row && primarySelectedCellY == col;

  void stopEditing() {
    editingMode = false;
    notifyListeners();
  }

  bool isReordering() {
    return sortUsecase.isReordering();
  }

  bool startEditing() {
    if (isReordering()) {
      return false;
    }
    editingMode = true;
    notifyListeners();
    return true;
  }

  void selectAll() {
    selectionUsecase.selectAll();
    notifyListeners();
  }

  void setPrimarySelection(int row, int col, bool keepSelection) {
    selectionUsecase.setPrimarySelection(row, col, keepSelection);
    notifyListeners();
  }
}
