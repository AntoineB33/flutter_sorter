import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/history_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sheet_data/sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/sort_service.dart';
import 'package:trying_flutter/features/media_sorter/data/services/spreadsheet_clipboard_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/analysis_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/loaded_sheets_data_store.dart';
import 'package:trying_flutter/features/media_sorter/presentation/store/selection_data_store.dart';
import 'package:uuid/uuid.dart';

class SheetDataController extends ChangeNotifier {
  // --- states ---
  final Map<String, ManageWaitingTasks<void>> _saveExecutors = {};
  
  final SheetDataController sheetDataController;
  final HistoryController historyController;
  final GridController gridController;

  final LoadedSheetsDataStore loadedSheetsData;
  final AnalysisDataStore analysisStore;
  final SelectionDataStore selectionDataStore;

  final SortService sortService;
  final HistoryService historyService;

  final SheetDataUsecase sheetDataUsecase;

  late final SpreadsheetClipboardService _clipboardService =
      SpreadsheetClipboardService();
  final ParsePasteDataUseCase _parsePasteDataUseCase;

  SheetData get currentSheet => loadedSheetsData.currentSheet;
  String get currentSheetName => loadedSheetsData.currentSheetId;
  int rowCount(SheetContent content) => content.table.length;
  int colCount(SheetContent content) =>
      content.table.isNotEmpty ? content.table[0].length : 0;

  final CalculationService calculationService = CalculationService();

  // --- usecases ---
  final SaveSheetDataUseCase _saveSheetDataUseCase;

  SheetDataController(this.sheetDataController, this.historyController, this.gridController,
    SaveSheetDataUseCase saveSheetDataUseCase,
    this.loadedSheetsData,
    this.analysisStore,
    this.selectionDataStore,
     this.sortService,
    this.historyService,
     this.sheetDataUsecase,
      this._parsePasteDataUseCase,
  ) : _saveSheetDataUseCase = saveSheetDataUseCase;

  void scheduleSheetSave(String sheetName) {
    _saveExecutors[sheetName]!.execute(() async {
      await _saveSheetDataUseCase.saveSheet(
        sheetName,
        loadedSheetsData.getSheet(sheetName),
      );
    });
  }

  void createSaveExecutor(String name) {
    _saveExecutors[name] = ManageWaitingTasks<void>(
      Duration(milliseconds: SpreadsheetConstants.saveSheetDelayMs),
    );
  }

  void onChanged(
    String newValue,
  ) {
    update(
      UpdateData(
        Uuid().v4(),
        DateTime.now(),
        [CellUpdate(
          selectionDataStore.primarySelectedCell.x,
          selectionDataStore.primarySelectedCell.y,
          newValue,
          loadedSheetsData.getCellContent(
            selectionDataStore.primarySelectedCell.x,
            selectionDataStore.primarySelectedCell.y,
          ),
        )],
      ), false);
    notifyListeners();
    scheduleSheetSave(currentSheetName);
    sortService.calculate(currentSheetName);
  }

  Future<bool> pasteSelection() async {
    final text = await _clipboardService.getText();
    if (text == null) return false;
    // if contains "
    if (text.contains('"')) {
      debugPrint('Paste data contains unsupported characters.');
      return false;
    }

    final UpdateData updateData = _parsePasteDataUseCase.pasteText(
      text,
      selectionDataStore.primarySelectedCell.x,
      selectionDataStore.primarySelectedCell.y,
    );
    update(updateData, true);
    return true;
  }

  void delete(
    SheetData sheet,
    Map<String, AnalysisResult> analysisResults,
    SelectionData selection,
    String currentSheetName,
    Map<String, SelectionData> lastSelectionBySheet,
    SortStatus sortStatus,
    double row1ToScreenBottomHeight,
    double colBToScreenRightWidth,
  ) {
    List<UpdateUnit> updates = [];
    for (Point<int> cell in selection.selectedCells) {
      updates.add(CellUpdate(
        cell.x,
        cell.y,
        '',
        loadedSheetsData.getCellContent(cell.x, cell.y),
      ));
    }
    UpdateData updateData = UpdateData(
      Uuid().v4(),
      DateTime.now(),
      updates,
    );
    update(updateData, true);
    notifyListeners();
    scheduleSheetSave(currentSheetName);
    sortService.calculate(currentSheetName);
  }

  void applyDefaultColumnSequence() {
    update(UpdateData(Uuid().v4(), DateTime.now(), [
      ColumnTypeUpdate(
        1,
        ColumnType.dependencies,
        loadedSheetsData.getColumnType(1),
      ),
      ColumnTypeUpdate(
        2,
        ColumnType.dependencies,
        loadedSheetsData.getColumnType(2),
      ),
      ColumnTypeUpdate(
        3,
        ColumnType.dependencies,
        loadedSheetsData.getColumnType(3),
      ),
      ColumnTypeUpdate(
        7,
        ColumnType.urls,
        loadedSheetsData.getColumnType(7),
      ),
      ColumnTypeUpdate(
        8,
        ColumnType.dependencies,
        loadedSheetsData.getColumnType(8),
      )]), true);
  }

  Future<void> copySelectionToClipboard(
    SheetData sheet,
    SelectionData selection,
    String currentSheetName,
  ) async {
    int startRow = selection.primarySelectedCell.x;
    int endRow = selection.primarySelectedCell.x;
    int startCol = selection.primarySelectedCell.y;
    int endCol = selection.primarySelectedCell.y;
    for (Point<int> cell in selection.selectedCells) {
      if (cell.x < startRow) startRow = cell.x;
      if (cell.y < startCol) startCol = cell.y;
      if (cell.x > endRow) endRow = cell.x;
      if (cell.y > endCol) endCol = cell.y;
    }
    List<List<bool>> selectedCellsTable = List.generate(
      endRow - startRow + 1,
      (_) => List.generate(endCol - startCol + 1, (_) => false),
    );
    for (Point<int> cell in selection.selectedCells) {
      selectedCellsTable[cell.x - startRow][cell.y - startCol] = true;
    }
    if (!selectedCellsTable.every((row) => row.every((cell) => !cell))) {
      await _clipboardService.copy(
        loadedSheetsData.getCellContent(
          selection.primarySelectedCell.x,
          selection.primarySelectedCell.y,
        ),
      );
      return;
    }

    StringBuffer buffer = StringBuffer();

    for (int r = startRow; r <= endRow; r++) {
      List<String> rowData = [];
      for (int c = startCol; c <= endCol; c++) {
        rowData.add(loadedSheetsData.getCellContent(r, c));
      }
      buffer.write(rowData.join('\t')); // Tab separated for Excel compat
      if (r < endRow) buffer.write('\n');
    }

    final text = buffer.toString();
    await _clipboardService.copy(text);
  }

  @override
  void dispose() {
    for (var executor in _saveExecutors.values) {
      executor.dispose();
    }
    super.dispose();
  }

  void update(UpdateData updateData, bool updateHistory) {
    sheetDataUsecase.update(updateData, updateHistory);
    gridController.adjustRowHeightAfterUpdate(updateData);
    notifyListeners();
    scheduleSheetSave(currentSheetName);
  }

  void moveInUpdateHistory(int direction) {
    final lastUpdate = historyController.moveInUpdateHistory(direction);
    if (lastUpdate != null) {
      sheetDataController.update(lastUpdate, false);
      sortService.calculate(loadedSheetsData.currentSheetId);
    }
  }
}
