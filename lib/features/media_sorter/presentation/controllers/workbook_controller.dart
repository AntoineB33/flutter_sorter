import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sorting_rule.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sheet_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/check_valid_strings.dart';
import 'package:trying_flutter/utils/logger.dart';
import 'dart:math';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/spreadsheet_scroll_request.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sort_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/delegates/spreadsheet_keyboard_delegate.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/delegates/spreadsheet_layout_delegate.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/services/sheet_loader_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/services/spreadsheet_clipboard_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/check_valid_strings.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart'; // Import AnalysisResult
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';

class WorkbookController extends ChangeNotifier {
  Map<String, SheetData> loadedSheetsData = {};
  Map<String, SelectionData> lastSelectionBySheet = {};
  Map<String, AnalysisResult> analysisResults = {};
  List<String> sheetNames = [];
  String currentSheetName = "";

  
  final GridController _gridController;
  final HistoryController _historyController;
  final SelectionController _selectionController;
  final SheetDataController _dataController;
  final TreeController _treeController;
  final SpreadsheetStreamController _streamController;
  final SortController _sortController;

  // --- usecases ---
  final SaveSheetDataUseCase _saveSheetDataUseCase = SaveSheetDataUseCase(
    SheetRepositoryImpl(FileSheetLocalDataSource()),
  );
  final GetSheetDataUseCase _getDataUseCase = GetSheetDataUseCase(
    SheetRepositoryImpl(FileSheetLocalDataSource()),
  );
  final CalculationService calculationService = CalculationService();
  final ParsePasteDataUseCase _parsePasteDataUseCase = ParsePasteDataUseCase();

  SelectionData get selection => lastSelectionBySheet[currentSheetName] ?? SelectionData.empty();
  
  List<List<String>> get table => sheet.sheetContent.table;
  int get rowCount => table.length;
  int get colCount => table.isNotEmpty ? table[0].length : 0;
  SheetData get sheet => loadedSheetsData[currentSheetName] ?? SheetData.empty();
  SheetContent get sheetContent => sheet.sheetContent;
  AnalysisResult get lastAnalysis => analysisResults[currentSheetName] ?? AnalysisResult.empty();
  NodeStruct get errorRoot => lastAnalysis.errorRoot;
  NodeStruct get warningRoot => lastAnalysis.warningRoot;
  NodeStruct get categoriesRoot => lastAnalysis.categoriesRoot;
  NodeStruct get distPairsRoot => lastAnalysis.distPairsRoot;
  Stream<SpreadsheetScrollRequest> get scrollStream =>
      _streamController.scrollStream;
  // bool get editingMode => _selectionController.editingMode;
  // int get tableViewRows => _selectionController.tableViewRows;
  // int get tableViewCols => _selectionController.tableViewCols;
  // Point<int> get primarySelectedCell =>
  //     _selectionController.primarySelectedCell;
  String get previousContent => selection.previousContent;
  bool get findingBestSort => _sortController.findingBestSort;

  // --- Helper ---
  late final SheetLoaderService _sheetLoaderService;

  // Delegates
  late final SpreadsheetKeyboardDelegate _keyboardDelegate;
  late final SpreadsheetLayoutDelegate _layoutDelegate;

  // Services
  late final SpreadsheetClipboardService _clipboardService;

  WorkbookController(
    this._gridController,
    this._historyController,
    this._selectionController,
    this._dataController,
    this._treeController,
    this._streamController,
    this._sortController,) {
    final SheetRepositoryImpl sheetRepository = SheetRepositoryImpl(
      FileSheetLocalDataSource(),
    );
    init();
  }

  Future<void> init() async {
    await _saveSheetDataUseCase.clearAllData();

    // --- get current sheet name and all sheet names ---
    String? lastOpenedSheetName;
    bool saveLastOpenedSheetName = false;
    bool saveAllSheetNames = false;
    try {
      lastOpenedSheetName = await _getDataUseCase.getLastOpenedSheetName();
    } catch (e) {
      debugPrint("Error getting last opened sheet name: $e");
    }
    try {
      sheetNames = await _getDataUseCase.getAllSheetNames();
    } catch (e) {
      debugPrint("Error initializing AllSheetsController: $e");
      sheetNames = [];
    }
    if (lastOpenedSheetName != null && !CheckValidStrings.isValidSheetName(lastOpenedSheetName!)) {
      debugPrint(
        "Invalid last opened sheet name '$lastOpenedSheetName'.",
      );
      lastOpenedSheetName = null;
    }
    for (var name in sheetNames) {
      if (!CheckValidStrings.isValidSheetName(name)) {
        debugPrint(
          "Invalid sheet name '$name' found in sheet names list, removing it.",
        );
        sheetNames.remove(name);
        saveAllSheetNames = true;
      }
    }
    if (lastOpenedSheetName == null) {
      if (sheetNames.isNotEmpty) {
        lastOpenedSheetName = sheetNames[0];
      } else {
        lastOpenedSheetName = SpreadsheetConstants.defaultSheetName;
        sheetNames = [lastOpenedSheetName];
      }
      saveLastOpenedSheetName = true;
    } else if (!sheetNames.contains(lastOpenedSheetName)) {
      logger.e(
        "Last opened sheet name '$lastOpenedSheetName' not found in sheet names list, adding it.",
      );
      sheetNames.add(lastOpenedSheetName);
      saveAllSheetNames = true;
    }
    currentSheetName = lastOpenedSheetName;

    // --- get last selection by sheet ---
    lastSelectionBySheet = await _selectionController.getAllLastSelected();
    bool saveLastSelectionBySheet = _selectionController.completeMissing(lastSelectionBySheet, sheetNames);
    for (var name in lastSelectionBySheet.keys.toList()) {
      if (CheckValidStrings.isValidSheetName(name)) {
        debugPrint(
          "Last selection found for sheet '$name' which is not in sheet names list, removing it.",
        );
        lastSelectionBySheet.remove(name);
        saveLastSelectionBySheet = true;
      } else if (!sheetNames.contains(name)) {
        sheetNames.add(name);
        saveAllSheetNames = true;
        debugPrint(
          "No sheet data saved for selection of sheet $name",
        );
      }
    }
    
    // --- get last selection for current sheet ---
    _selectionController.getLastSelection(lastSelectionBySheet, currentSheetName);

    // --- save any correction if needed ---
    if (saveLastOpenedSheetName) {
      await _saveSheetDataUseCase.saveLastOpenedSheetName(currentSheetName);
    }
    if (saveAllSheetNames) {
      await _saveSheetDataUseCase.saveAllSheetNames(sheetNames);
    }
    if (saveLastSelectionBySheet) {
      _selectionController.saveAllLastSelected(lastSelectionBySheet);
    }

    loadSheetByName(currentSheetName, init: true);
  }

  
  Future<void> loadSheetByName(
    String name, {
    bool init = false,
    SelectionData? lastSelection,
  }) async {
    if (!init) {
      _selectionController.saveAllLastSelected(lastSelectionBySheet);
      _saveSheetDataUseCase.saveLastOpenedSheetName(name);
    }

    if (sheetNames.contains(name)) {
      if (!loadedSheetsData.containsKey(name)) {
        _dataController.createSaveExecutor(name);
        try {
          loadedSheetsData[name] = await _getDataUseCase.loadSheet(name);
        } catch (e) {
          logger.e("Error parsing sheet data for $name: $e");
          loadedSheetsData[name] = SheetData.empty();
          _selectionController.clearLastSelection(lastSelectionBySheet, name);
        }
      }
    } else {
      loadedSheetsData[name] = SheetData.empty();
      _selectionController.clearLastSelection(lastSelectionBySheet, name);
      sheetNames.add(name);
      _saveSheetDataUseCase.saveAllSheetNames(sheetNames);
      _dataController.createSaveExecutor(name);
    }
    currentSheetName = name;
    if (!init) {
      _selectionController.saveLastSelection(lastSelectionBySheet, name);
    }

    // Trigger Controller updates
    updateRowColCount(
      visibleHeight:
          selection.scrollOffsetX +
          _gridController.row1ToScreenBottomHeight,
      visibleWidth:
          selection.scrollOffsetY +
          _gridController.colBToScreenRightWidth,
      notify: false,
    );

    _streamController.scrollToOffset(
      x: selection.scrollOffsetX,
      y: selection.scrollOffsetY,
      animate: true,
    );

    saveAndCalculate(save: false);
    notifyListeners();
  }

  
  void updateRowColCount({
    double? visibleHeight,
    double? visibleWidth,
    bool notify = true,
    bool save = true,
  }) {
    var (targetRows, targetCols) = _gridController.updateRowColCount(
      selection,
      sheet,
      rowCount,
      colCount,
      visibleHeight: visibleHeight,
      visibleWidth: visibleWidth,
    );
    _selectionController.updateRowColCount(
      selection,
      lastSelectionBySheet,
      targetRows,
      targetCols,
      currentSheetName,
      notify: notify,
      save: save,
    );
  }

  
  void saveAndCalculate({bool save = true, bool updateHistory = false}) {
    if (save) {
      if (updateHistory) {
        _historyController.commitHistory(sheet);
      }
      _dataController.scheduleSheetSave(sheet, currentSheetName, SpreadsheetConstants.saveDelayMs);
    }
    _sortController.clear();
    _sortController.calculate(
      sheet.sheetContent,
      rowCount,
      colCount,
      onAnalysisComplete,
      selection,
      _sortController,
    );
  }

  /// Call this when the Controller finishes a calculation.
  /// The Manager takes ownership of updating the tree state.
  void onAnalysisComplete(
    AnalysisResult result,
    Point<int> primarySelectedCell,
  ) {
    // Reset specific roots
    _treeController.updateMentionsRoot(primarySelectedCell.x, primarySelectedCell.y);
    _treeController.clearSearchRoot();
    _treeController.populateAllTrees(selection, sheet, result, rowCount, colCount);
  }

  void applyDefaultColumnSequence() {
    setColumnType(1, ColumnType.dependencies);
    setColumnType(2, ColumnType.dependencies);
    setColumnType(3, ColumnType.dependencies);
    setColumnType(7, ColumnType.urls);
    setColumnType(8, ColumnType.dependencies);
  }

  void stopEditing({bool updateHistory = true, bool notify = true}) {
    selection.editingMode = false;
    _selectionController.saveLastSelection(lastSelectionBySheet, currentSheetName);
    if (notify) {
      notifyListeners();
    }
    if (updateHistory && sheet.currentUpdateHistory != null) {
      _historyController.commitHistory(sheet);
    } else {
      _historyController.discardPendingChanges(sheet);
    }
  }

  void startEditing({String? initialInput}) {
    selection.previousContent = _selectionController.getCellContent(table,
      selection.primarySelectedCell.x,
      selection.primarySelectedCell.y,
    );
    if (initialInput != null) {
      _dataController.onChanged(initialInput);
    }
    selection.editingMode = true;
    _selectionController.saveLastSelection(lastSelectionBySheet, currentSheetName);
    notifyListeners();
  }

  void delete() {
    for (Point<int> cell in selection.selectedCells) {
      updateCell(cell.x, cell.y, '', keepPrevious: true);
    }
    updateCell(
      selection.primarySelectedCell.x,
      selection.primarySelectedCell.y,
      '',
      keepPrevious: true,
    );
    notifyListeners();
    saveAndCalculate(updateHistory: true);
  }

  void setColumnType(int col, ColumnType type, {bool updateHistory = true}) {
    ColumnType previousType = GetNames.getColumnType(
      sheetContent,
      col,
    );
    if (updateHistory) {
      _historyController.recordColumnTypeChange(sheet.currentUpdateHistory, col, previousType, type);
    }
    if (type == ColumnType.attributes) {
      if (col < colCount) {
        if (GetNames.isSourceColumn(previousType)) {
          _dataController.removeSourceColId(col);
        }
        _dataController.sheetContent.columnTypes[col] = type;
        if (col == _dataController.sheetContent.columnTypes.length - 1) {
          while (col > 0) {
            col--;
            if (_dataController.sheetContent.columnTypes[col] !=
                ColumnType.attributes) {
              break;
            }
          }
          _dataController.sheetContent.columnTypes = _dataController
              .sheetContent
              .columnTypes
              .sublist(0, col + 1);
        }
      }
    } else {
      _dataController.increaseColumnCount(col);
      _dataController.sheetContent.columnTypes[col] = type;
      if (GetNames.isSourceColumn(type)) {
        _dataController.addSourceColId(col);
      }
    }
    notifyListeners();
    saveAndCalculate(updateHistory: true);
  }

  void undo() {
    final sheet = _dataController.sheet;
    if (sheet.historyIndex < 0 || sheet.updateHistories.isEmpty) {
      return;
    }
    final lastUpdate = sheet.updateHistories[sheet.historyIndex];
    if (lastUpdate.key == UpdateHistory.updateCellContent) {
      for (var cellUpdate in lastUpdate.updatedCells!) {
        updateCell(
          cellUpdate.cell.x,
          cellUpdate.cell.y,
          cellUpdate.previousValue,
          historyNavigation: true,
        );
      }
    } else if (lastUpdate.key == UpdateHistory.updateColumnType) {
      for (var typeUpdate in lastUpdate.updatedColumnTypes!) {
        setColumnType(
          typeUpdate.colId!,
          typeUpdate.previousColumnType!,
          updateHistory: false,
        );
      }
    }
    sheet.historyIndex--;
    notifyListeners();
    saveAndCalculate();
  }

  void redo() {
    final sheet = _dataController.sheet;
    if (sheet.historyIndex + 1 == sheet.updateHistories.length) {
      return;
    }
    final nextUpdate = sheet.updateHistories[sheet.historyIndex + 1];
    if (nextUpdate.key == UpdateHistory.updateCellContent) {
      for (var cellUpdate in nextUpdate.updatedCells!) {
        updateCell(
          cellUpdate.cell.x,
          cellUpdate.cell.y,
          cellUpdate.newValue,
          historyNavigation: true,
        );
      }
    } else if (nextUpdate.key == UpdateHistory.updateColumnType) {
      for (var typeUpdate in nextUpdate.updatedColumnTypes!) {
        setColumnType(
          typeUpdate.colId!,
          typeUpdate.newColumnType!,
          updateHistory: false,
        );
      }
    }
    sheet.historyIndex++;
    notifyListeners();
    saveAndCalculate();
  }

  Future<void> pasteSelection() async {
    final text = await _clipboardService.getText();
    if (text == null) return;
    // if contains "
    if (text.contains('"')) {
      debugPrint('Paste data contains unsupported characters.');
      return;
    }

    final List<CellUpdate> updates = _parsePasteDataUseCase.pasteText(
      text,
      _selectionController.primarySelectedCell.x,
      _selectionController.primarySelectedCell.y,
    );
    setTable(updates);
  }

  void setTable(List<CellUpdate> updates) {
    sheet.currentUpdateHistory = null;
    for (var update in updates) {
      updateCell(update.row, update.col, update.value, keepPrevious: true);
    }
    notifyListeners();
    saveAndCalculate(updateHistory: true);
  }

  void updateCell(
    int row,
    int col,
    String newValue, {
    bool onChange = false,
    bool historyNavigation = false,
    bool keepPrevious = false,
  }) {
    String prevValue = _dataController.updateCell(row, col, newValue);
    if (!historyNavigation) {
      _historyController.recordCellChange(
        row,
        col,
        prevValue,
        newValue,
        onChange,
        keepPrevious,
      );
    }

    // Delegate layout calculation to GridManager
    adjustRowHeightAfterUpdate(row, col, newValue, prevValue);
  }

  void adjustRowHeightAfterUpdate(
    int row,
    int col,
    String newValue,
    String prevValue,
  ) {
    return _layoutDelegate.adjustRowHeightAfterUpdate(
      row,
      col,
      newValue,
      prevValue,
    );
  }

  void selectAll() {
    _selectionController.selectedCells.clear();
    for (int r = 0; r < rowCount; r++) {
      for (int c = 0; c < colCount; c++) {
        _selectionController.selectedCells.add(Point(r, c));
      }
    }
    setPrimarySelection(0, 0, true, true);
  }

  // Method to allow Controller to toggle expansion
  void toggleNodeExpansion(NodeStruct node, bool isExpanded) {
    node.isExpanded = isExpanded;
    for (NodeStruct child in node.newChildren ?? []) {
      child.isExpanded = false;
    }
    _treeBuilder.populateTree([node]);
    notifyListeners();
  }

  Future<void> copySelectionToClipboard() async {
    int startRow = _selectionController.primarySelectedCell.x;
    int endRow = _selectionController.primarySelectedCell.x;
    int startCol = _selectionController.primarySelectedCell.y;
    int endCol = _selectionController.primarySelectedCell.y;
    for (Point<int> cell in _selectionController.selectedCells) {
      if (cell.x < startRow) startRow = cell.x;
      if (cell.y < startCol) startCol = cell.y;
      if (cell.x > endRow) endRow = cell.x;
      if (cell.y > endCol) endCol = cell.y;
    }
    List<List<bool>> selectedCellsTable = List.generate(
      endRow - startRow + 1,
      (_) => List.generate(endCol - startCol + 1, (_) => false),
    );
    for (Point<int> cell in _selectionController.selectedCells) {
      selectedCellsTable[cell.x - startRow][cell.y - startCol] = true;
    }
    if (!selectedCellsTable.every((row) => row.every((cell) => !cell))) {
      await _clipboardService.copy(
        _dataController.getCellContent(
          _selectionController.primarySelectedCell.x,
          _selectionController.primarySelectedCell.y,
        ),
      );
      return;
    }

    StringBuffer buffer = StringBuffer();

    for (int r = startRow; r <= endRow; r++) {
      List<String> rowData = [];
      for (int c = startCol; c <= endCol; c++) {
        rowData.add(_dataController.getCellContent(r, c));
      }
      buffer.write(rowData.join('\t')); // Tab separated for Excel compat
      if (r < endRow) buffer.write('\n');
    }

    final text = buffer.toString();
    await _clipboardService.copy(text);
  }

  void notify() {
    notifyListeners();
  }

  bool canBeSorted() {
    return _sortController.canBeSorted();
  }

  bool isRowValid(int rowId) {
    if (_sortController.canBeSorted()) {
      return _treeController.isMedium[rowId];
    }
    if (rowId == 0) {
      return false;
    }
    for (int srcColId = 0; srcColId < colCount; srcColId++) {
      if (GetNames.isSourceColumn(_dataController.sheetContent.columnTypes[srcColId]) && _dataController.getCellContent(rowId, srcColId).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  void sortMedia() {
    stopEditing(notify: false);
    List<int> validRowIndexes = _treeController.validRowIndexes;
    List<int> sortOrder = [0];
    List<int> stack = _sortController.bestMediaSortOrder!
        .asMap()
        .entries
        .map((e) => validRowIndexes[e.key])
        .toList()
        .reversed
        .toList();
    final rowToRowRefs = _treeController.rowToRefFromAttCol;
    final table = _dataController.sheetContent.table;
    List<int> added = List.filled(table.length, 0);
    for (int i in stack) {
      added[i] = 1;
    }
    List<String> toNewPlacement = List.filled(table.length, '');
    for (int rowId in _treeController.validRowIndexes) {
      stack.add(rowId);
      while (stack.isNotEmpty) {
        int current = stack[stack.length - 1];
        if (added[current] == 2) {
          stack.removeLast();
          continue;
        }
        for (int ref in rowToRowRefs[current]) {
          if (added[ref] != 2) {
            stack.add(ref);
            added[ref] = 1;
          }
        }
        if (stack[stack.length - 1] == current) {
          toNewPlacement[current] = sortOrder.length.toString();
          sortOrder.add(current);
          stack.removeLast();
          added[current] = 2;
        }
      }
    }
    for (int rowId = 1; rowId < table.length; rowId++) {
      if (added[rowId] == 0) {
        sortOrder.add(rowId);
      }
    }
    List<List<StrInt>> formatedTable = _treeController.formatedTable;
    List<List<String>> sortedTable = sortOrder.map((i) => table[i]).toList();
    for (int rowId = 1; rowId < rowCount; rowId++) {
      for (int colId = 0; colId < colCount; colId++) {
        if (formatedTable[rowId][colId].integers.isEmpty) {
          continue;
        }
        for (
          int splitId = 0;
          splitId < formatedTable[rowId][colId].strings.length;
          splitId++
        ) {
          sortedTable[rowId][colId] =
              formatedTable[rowId][colId].strings[splitId];
          if (formatedTable[rowId][colId].integers.length <= splitId) {
            break;
          }
          sortedTable[rowId][colId] +=
              toNewPlacement[formatedTable[rowId][colId].integers[splitId]];
        }
      }
    }
    final List<CellUpdate> updates = [];
    for (int rowId = 1; rowId < sortedTable.length; rowId++) {
      for (int colId = 0; colId < sortedTable[rowId].length; colId++) {
        updates.add(
          CellUpdate(row: rowId, col: colId, value: sortedTable[rowId][colId]),
        );
      }
    }
    setTable(updates);
  }

  Future<void> findBestSortToggle() async {
    if (_sortController.findingBestSort) {
    } else {
      stopEditing(notify: false);

      final service = SortingService();

      try {
        // await for pauses the execution of this function
        // until the stream is closed by the server.
        await for (final solution in service.solveSortingStream(
          nVal,
          myRules,
        )) {
          _sortController.setBestMediaSortOrder(solution);
        }
      } catch (error) {
        _sortController.clear();
        result.errorRoot.newChildren!.add(
          NodeStruct(
            message:
                "Could not find a valid sorting satisfying all constraints.",
          ),
        );
      }
    }
    _sortController.findingBestSort = !_sortController.findingBestSort;
  }
}
