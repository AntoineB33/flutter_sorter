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

  int get currentSheetId => workbookUsecase.currentSheetId;
  int get primarySelectedCellX => selectionUsecase.primarySelectedCellX;
  int get primarySelectedCellY => selectionUsecase.primarySelectedCellY;

  SelectionController(
    this.selectionUsecase,
    this.sortUsecase,
    this.historyUsecase,
    this.workbookUsecase,
    this.sheetDataUsecase,
  );

  SelectionData getSelectionData(int sheetId) {
    return selectionUsecase.getSelectionData(sheetId);
  }

  bool isCellSelected(int row, int col) {
    return selectionUsecase
        .getSelectionData(currentSheetId)
        .selectedCells
        .any((cell) => cell.rowId == row && cell.colId == col);
  }

  bool isPrimarySelectedCell(int row, int col) {
    return row == primarySelectedCellX && col == primarySelectedCellY;
  }

  bool isCellEditing(int row, int col) =>
      editingMode && primarySelectedCellX == row && primarySelectedCellY == col;

  void stopEditing(bool escape, {Map<String, UpdateUnit>? updates}) {
    historyUsecase.stopEditing(escape, updates: updates);
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
  }
}
