import 'dart:math';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history/history_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/analysis_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/selection_data_store.dart';

class SelectionController extends ChangeNotifier {
  final LoadedSheetsDataStore loadedSheetsDataStore;
  final AnalysisDataStore analysisStore;
  final SelectionDataStore selectionDataStore;
  final HistoryController historyController;
  final HistoryService historyService;

  final ManageWaitingTasks<void> _saveLastSelectionExecutor =
      ManageWaitingTasks<void>(Duration(milliseconds: 1000));

  final GetSheetDataUseCase _getDataUseCase;
  final SaveSheetDataUseCase _saveSheetDataUseCase;

  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) =>
      content.table.isNotEmpty ? content.table[0].length : 0;

  SelectionController(
    this._getDataUseCase,
    this._saveSheetDataUseCase,
    this.selectionDataStore,
    this.loadedSheetsDataStore,
    this.analysisStore,
    this.historyController,
    this.historyService,
  ) {
    selectionDataStore.addListener(() {
      saveLastSelection();
    });
  }

  Future<void> getAllLastSelected() async {
    try {
      selectionDataStore.lastSelectionBySheet = await _getDataUseCase
          .getAllLastSelected();
    } catch (e) {
      debugPrint("Error getting all last selected cells: $e");
    }
  }

  bool completeMissing(List<String> sheetNames) {
    bool saveLastSelectionBySheet = false;
    for (var name in sheetNames) {
      if (!lastSelectionBySheet.containsKey(name)) {
        lastSelectionBySheet[name] = SelectionData.empty();
        saveLastSelectionBySheet = true;
        debugPrint("No last selection saved for sheet $name");
      }
    }
    return saveLastSelectionBySheet;
  }

  Future<void> loadLastSelection() async {
    try {
      selectionDataStore.lastSelectionBySheet[loadedSheetsDataStore
          .currentSheetName] = await _getDataUseCase
          .getLastSelection();
    } catch (e) {
      debugPrint("Error getting last selection for current sheet: $e");
      selectionDataStore.lastSelectionBySheet[loadedSheetsDataStore
              .currentSheetName] =
          SelectionData.empty();
    }
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
      await Future.delayed(
        Duration(milliseconds: SpreadsheetConstants.saveSheetDelayMs),
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
      triggerScrollTo(row, col);
    }
    notifyListeners();
  }

  void stopEditing({bool updateHistory = true}) {
    if (!selectionDataStore.editingMode) {
      return;
    }
    saveLastSelection();
    if (updateHistory) {
      historyService.commitHistory();
    }
    selectionDataStore.setEditingMode(false);
  }

  void startEditing(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    Map<String, SelectionData> lastSelectionBySheet,
    SortStatus sortStatus,
    String currentSheetName,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth, {
    String? initialInput,
  }) {
    SelectionData selection = lastSelectionBySheet[currentSheetName]!;
    if (sortStatus.sortWhileFindingBestSort) {
      return;
    }
    selection.previousContent = getCellContent(
      sheet.sheetContent.table,
      selection.primarySelectedCell.x,
      selection.primarySelectedCell.y,
    );
    if (initialInput != null) {
      onChanged(
        sheet,
        analysisResults,
        selection,
        lastSelectionBySheet,
        sortStatus,
        row1ToScreenBottomHeight,
        colBToScreenRightWidth,
        currentSheetName,
        initialInput,
      );
    }
    selection.editingMode = true;
    saveLastSelection(currentSheetName);
    notifyListeners();
  }

  void selectAll(
    SelectionData selection,
    Map<String, SelectionData> lastSelectionBySheet,
    String currentSheetName,
    int rowCount,
    int colCount,
  ) {
    selection.selectedCells.clear();
    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        selection.selectedCells.add(Point(r, c));
      }
    }
    setPrimarySelection(currentSheetName, 0, 0, true);
  }
}
