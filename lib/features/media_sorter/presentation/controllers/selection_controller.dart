import 'dart:math';
import 'package:isar/isar.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/history_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/analysis_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/selection_data_store.dart';
import 'package:uuid/uuid.dart';

class SelectionController extends ChangeNotifier {
  final HistoryController historyController;
  final GridController gridController;

  final HistoryService historyService;

  final LoadedSheetsDataStore loadedSheetsDataStore;
  final AnalysisDataStore analysisStore;
  final SelectionDataStore selectionDataStore;
  final SortStatus sortStatus;


  final ManageWaitingTasks<void> _saveLastSelectionExecutor =
      ManageWaitingTasks<void>(Duration(milliseconds: 1000));

  final GetSheetDataUseCase _getDataUseCase;
  final SaveSheetDataUseCase _saveSheetDataUseCase;

  SheetData get currentSheet => loadedSheetsDataStore.currentSheet;
  SheetContent get currentSheetContent => currentSheet.sheetContent;
  int get rowCount => currentSheetContent.table.length;
  int get colCount =>
      currentSheetContent.table.isNotEmpty ? currentSheetContent.table[0].length : 0;
  SelectionData get selection => selectionDataStore.selection;

  SelectionController(
    this._getDataUseCase,
    this._saveSheetDataUseCase,
    this.selectionDataStore,
    this.loadedSheetsDataStore,
    this.analysisStore,
    this.historyController,
    this.historyService,
    this.gridController,
    this.sortStatus,
  ) {
    selectionDataStore.addListener(() {
      saveLastSelection();
    });
  }

  Future<void> getAllLastSelected() async {
    final result = await _getDataUseCase
        .getAllLastSelected();
    result.fold(
      (failure) {
        debugPrint("Error getting all last selected: $failure");
      },
      (lastSelected) {
        selectionDataStore.lastSelectionBySheet = lastSelected;
      },
    );
  }

  bool completeMissing(List<String> sheetNames) {
    bool saveLastSelectionBySheet = false;
    for (var name in sheetNames) {
      if (!selectionDataStore.lastSelectionBySheet.containsKey(name)) {
        selectionDataStore.lastSelectionBySheet[name] = SelectionData.empty();
        saveLastSelectionBySheet = true;
        debugPrint("No last selection saved for sheet $name");
      }
    }
    return saveLastSelectionBySheet;
  }

  Future<void> loadLastSelection() async {
    final result = await _getDataUseCase
          .getLastSelection();
    result.fold(
      (failure) {
        debugPrint("Error getting last selection for current sheet: $failure");
        selectionDataStore.lastSelectionBySheet[loadedSheetsDataStore
                .currentSheetId] =
            SelectionData.empty();
      },
      (selection) {
        selectionDataStore.lastSelectionBySheet[loadedSheetsDataStore
                .currentSheetId] =
            selection;
      }
    );
  }

  void clearLastSelection(String sheetName) {
    selectionDataStore.lastSelectionBySheet[sheetName] = SelectionData.empty();
  }

  Future<void> saveAllLastSelected() async {
    await _saveSheetDataUseCase.saveAllLastSelected(
      selectionDataStore.lastSelectionBySheet,
    );
  }

  Future<void> saveLastSelection() async {
    _saveLastSelectionExecutor.execute(() async {
      await _saveSheetDataUseCase.saveLastSelection(
        selectionDataStore.selection,
      );
    });
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
    SelectionData selection = selectionDataStore.selection;
    if (!keepSelection) {
      selection.selectedCells.clear();
    }
    selection.primarySelectedCell = Point(row, col);
    saveLastSelection();

    // Request scroll to visible
    if (scrollTo) {
      gridController.scrollToCell(row, col);
    }
    notifyListeners();
  }

  void stopEditing(String prevValue, {bool updateHistory = true}) {
    if (!selectionDataStore.editingMode) {
      return;
    }
    saveLastSelection();
    if (updateHistory) {
      historyService.commitHistory(
        UpdateData(Uuid().v4(), DateTime.now(), [
          CellUpdate(
            selectionDataStore.primarySelectedCell.x,
            selectionDataStore.primarySelectedCell.y,
            loadedSheetsDataStore.getCellContent(
              selectionDataStore.primarySelectedCell.x,
              selectionDataStore.primarySelectedCell.y,
            ),
            prevValue,
          ),
        ]),
      );
    }
    selectionDataStore.setEditingMode(false);
  }

  bool startEditing() {
    if (sortStatus.sortWhileFindingBestSort) {
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
    super.dispose();
  }

  void setPrimarySelection(
    int row,
    int col,
    bool keepSelection, {
    bool scrollTo = true,
  }) {
    selectionController.setPrimarySelection(row, col, keepSelection, scrollTo: scrollTo);
    
    treeController.updateMentionsContext(row, col);
  }
}
