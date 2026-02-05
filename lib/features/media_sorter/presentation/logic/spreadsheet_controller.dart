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
import 'package:trying_flutter/features/media_sorter/presentation/logic/tree_structure_builder.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/check_valid_strings.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart'; // Import AnalysisResult
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';

class SpreadsheetController extends ChangeNotifier {
  // --- dependencies ---
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

  // --- getters ---
  int get rowCount => _dataController.rowCount;
  int get colCount => _dataController.colCount;
  String get sheetName => _dataController.sheetName;
  SheetData get sheet => _dataController.sheet;
  SheetContent get sheetContent => _dataController.sheetContent;
  List<String> get sheetNames => _dataController.sheetNames;
  NodeStruct get errorRoot => _treeController.errorRoot;
  NodeStruct get warningRoot => _treeController.warningRoot;
  NodeStruct get mentionsRoot => _treeController.mentionsRoot;
  NodeStruct get searchRoot => _treeController.searchRoot;
  NodeStruct get categoriesRoot => _treeController.categoriesRoot;
  NodeStruct get distPairsRoot => _treeController.distPairsRoot;
  Stream<SpreadsheetScrollRequest> get scrollStream =>
      _streamController.scrollStream;
  bool get editingMode => _selectionController.editingMode;
  int get tableViewRows => _selectionController.tableViewRows;
  int get tableViewCols => _selectionController.tableViewCols;
  Point<int> get primarySelectedCell =>
      _selectionController.primarySelectedCell;
  String get previousContent => _selectionController.selection.previousContent;
  bool get findingBestSort => _sortController.findingBestSort;

  // --- redirections ---
  KeyEventResult handleKeyboard(BuildContext context, KeyEvent event) =>
      _keyboardDelegate.handle(context, event);
  void updateRowColCount({
    double? visibleHeight,
    double? visibleWidth,
    bool notify = true,
    bool save = true,
  }) {
    _layoutDelegate.updateRowColCount(
      visibleHeight: visibleHeight,
      visibleWidth: visibleWidth,
      notify: notify,
      save: save,
    );
  }

  Future<void> loadSheetByName(
    String name, {
    bool init = false,
    SelectionData? lastSelection,
  }) async {
    await _sheetLoaderService.loadSheetByName(
      name,
      init: init,
      lastSelection: lastSelection,
    );
  }

  // --- Helper ---
  late final TreeStructureBuilder _treeBuilder;
  late final SheetLoaderService _sheetLoaderService;

  // Delegates
  late final SpreadsheetKeyboardDelegate _keyboardDelegate;
  late final SpreadsheetLayoutDelegate _layoutDelegate;

  // Services
  late final SpreadsheetClipboardService _clipboardService;

  SpreadsheetController(
    this._gridController,
    this._historyController,
    this._selectionController,
    this._dataController,
    this._treeController,
    this._streamController,
    this._sortController,
  ) {
    // Initialize the builder passing the required controllers and the callback
    _treeBuilder = TreeStructureBuilder(
      dataController: _dataController,
      selectionController: _selectionController,
      treeController: _treeController,
      onCellSelected: (row, col, keep, updateMentions) {
        setPrimarySelection(row, col, keep, updateMentions);
      },
    );
    _sheetLoaderService = SheetLoaderService(
      _gridController,
      _selectionController,
      _dataController,
      _streamController,
      _saveSheetDataUseCase,
      _getDataUseCase,
      notifyListeners,
      updateRowColCount,
      saveAndCalculate,
    );
    _clipboardService = SpreadsheetClipboardService(_dataController);
    _keyboardDelegate = SpreadsheetKeyboardDelegate(this);
    _layoutDelegate = SpreadsheetLayoutDelegate(
      this,
      _gridController,
      _selectionController,
      _dataController,
    );
    init();
  }

  void saveAndCalculate({bool save = true, bool updateHistory = false}) {
    if (save) {
      if (updateHistory) {
        commitHistory();
      }
      _dataController.scheduleSheetSave(SpreadsheetConstants.saveDelayMs);
    }
    _sortController.clear();
    _dataController.calculateExecutor.execute(
      () async {
        AnalysisResult result = await calculationService.runCalculation(
          _dataController.sheetContent,
        );

        int nVal = result.instrTable.length;
        if (result.errorRoot.newChildren!.isNotEmpty || nVal == 0) {
          return result;
        }

        myRules = {};
        for (int rowId = 0; rowId < nVal; rowId++) {
          myRules[rowId] = [];
          for (final instr in result.instrTable[rowId].keys) {
            if (!instr.isConstraint) {
              continue;
            }
            for (int target in instr.numbers) {
              for (final interval in instr.intervals) {
                int minVal = interval[0];
                int maxVal = interval[1];
                myRules[rowId]!.add(
                  SortingRule(
                    minVal: minVal,
                    maxVal: maxVal,
                    relativeTo: target,
                  ),
                );
              }
            }
          }
        }

        debugPrint("Sending request...");
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
        return result;
      },
      onComplete: (AnalysisResult result) {
        result.rowCount = rowCount;
        result.colCount = colCount;
        result.noResult = false;

        onAnalysisComplete(result, _selectionController.primarySelectedCell);
        notifyListeners();
      },
    );
  }

  void setPrimarySelection(
    int row,
    int col,
    bool keepSelection,
    bool updateMentions, {
    bool scrollTo = true,
  }) {
    if (!keepSelection) {
      _selectionController.selectedCells.clear();
    }
    _selectionController.primarySelectedCell = Point(row, col);
    _dataController.saveLastSelection(_selectionController.selection);

    // Update Mentions
    if (updateMentions) {
      _treeController.mentionsRoot.newChildren = null;
      _treeController.mentionsRoot.rowId = row;
      _treeController.mentionsRoot.colId = col;
      _treeBuilder.populateTree([_treeController.mentionsRoot]);
    }

    // Request scroll to visible
    if (scrollTo) {
      _streamController.triggerScrollTo(row, col);
    }
    notifyListeners();
  }

  /// Call this when the Controller finishes a calculation.
  /// The Manager takes ownership of updating the tree state.
  void onAnalysisComplete(
    AnalysisResult result,
    Point<int> primarySelectedCell,
  ) {
    _treeController.lastAnalysis = result;

    // Reset specific roots
    _treeController.mentionsRootChildren = null;
    _treeController.mentionsRootRowId = primarySelectedCell.x;
    _treeController.mentionsRootColId = primarySelectedCell.y;
    _treeController.searchRootChildren = null;

    // Populate the full tree using the new result
    _treeBuilder.populateTree([
      result.errorRoot,
      result.warningRoot,
      _treeController.mentionsRoot,
      _treeController.searchRoot,
      result.categoriesRoot,
      result.distPairsRoot,
    ]);
  }

  void onChanged(String newValue) {
    updateCell(
      _selectionController.primarySelectedCell.x,
      _selectionController.primarySelectedCell.y,
      newValue,
      onChange: true,
    );
    notifyListeners();
    saveAndCalculate();
  }

  void applyDefaultColumnSequence() {
    setColumnType(1, ColumnType.dependencies);
    setColumnType(2, ColumnType.dependencies);
    setColumnType(3, ColumnType.dependencies);
    setColumnType(7, ColumnType.urls);
    setColumnType(8, ColumnType.dependencies);
  }

  /// Commits the `currentUpdateHistory` to the Sheet's permanent history stack.
  void commitHistory() {
    final sheet = _dataController.sheet;
    if (sheet.historyIndex < sheet.updateHistories.length - 1) {
      sheet.updateHistories = sheet.updateHistories.sublist(
        0,
        sheet.historyIndex + 1,
      );
    }
    sheet.updateHistories.add(_historyController.currentUpdateHistory!);
    sheet.historyIndex++;
    if (sheet.historyIndex == SpreadsheetConstants.historyMaxLength) {
      sheet.updateHistories.removeAt(0);
      sheet.historyIndex--;
    }
    _historyController.discardCurrent();
  }

  void stopEditing({bool updateHistory = true, bool notify = true}) {
    _selectionController.editingMode = false;
    _dataController.saveLastSelection(_selectionController.selection);
    if (notify) {
      notifyListeners();
    }
    if (updateHistory && _historyController.currentUpdateHistory != null) {
      commitHistory();
    } else {
      _historyController.discardCurrent();
    }
  }

  void startEditing({String? initialInput}) {
    _selectionController.previousContent = _dataController.getContent(
      _selectionController.primarySelectedCell.x,
      _selectionController.primarySelectedCell.y,
    );
    if (initialInput != null) {
      onChanged(initialInput);
    }
    _selectionController.editingMode = true;
    _dataController.saveLastSelection(_selectionController.selection);
    notifyListeners();
  }

  void delete() {
    for (Point<int> cell in _selectionController.selectedCells) {
      updateCell(cell.x, cell.y, '', keepPrevious: true);
    }
    updateCell(
      _selectionController.primarySelectedCell.x,
      _selectionController.primarySelectedCell.y,
      '',
      keepPrevious: true,
    );
    notifyListeners();
    saveAndCalculate(updateHistory: true);
  }

  void setColumnType(int col, ColumnType type, {bool updateHistory = true}) {
    ColumnType previousType = GetNames.getColumnType(
      _dataController.sheetContent,
      col,
    );
    if (updateHistory) {
      _historyController.recordColumnTypeChange(col, previousType, type);
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
    _historyController.discardCurrent();
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
        _dataController.getContent(
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
        rowData.add(_dataController.getContent(r, c));
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
    for (int srcColId in sheetContent.sourceColIndices) {
      if (_dataController.getContent(rowId, srcColId).isNotEmpty) {
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
