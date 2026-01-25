import 'dart:math';
import 'package:flutter/services.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/file_sheet_local_datasource.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';
import 'package:trying_flutter/features/media_sorter/data/repositories/sheet_repository_impl.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/spreadsheet_scroll_request.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/get_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/delegates/spreadsheet_keyboard_delegate.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/tree_structure_builder.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/check_valid_strings.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/get_default_sizes.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart'; // Import AnalysisResult
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/utils/logger.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';

class GridHistorySelectionDataTreeStreamManager extends ChangeNotifier {
  // --- dependencies ---
  final GridController _gridController;
  final HistoryController _historyController;
  final SelectionController _selectionController;
  final SheetDataController _dataController;
  final TreeController _treeController;
  final SpreadsheetStreamController _streamController;

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
  String get sheetName => _dataController.sheetName;
  SheetModel get sheet => _dataController.sheet;
  SheetContent get sheetContent => _dataController.sheetContent;
  List<String> get availableSheets => _dataController.availableSheets;
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
  
  // --- Helper ---
  late final TreeStructureBuilder _treeBuilder;
  
  // Delegates
  late final SpreadsheetClipboardService _clipboardService;
  late final SpreadsheetKeyboardDelegate _keyboardDelegate;

  GridHistorySelectionDataTreeStreamManager(
    this._gridController,
    this._historyController,
    this._selectionController,
    this._dataController,
    this._treeController,
    this._streamController,
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
    _clipboardService = SpreadsheetClipboardService(_dataController);
    _keyboardDelegate = SpreadsheetKeyboardDelegate(this);
    init();
  }

  void saveAndCalculate({bool save = true, bool updateHistory = false}) {
    if (save) {
      if (updateHistory) {
        commit();
      }
      _dataController.scheduleSheetSave(SpreadsheetConstants.saveDelayMs);
    }
    _dataController.calculateExecutor.execute(
      () async {
        AnalysisResult result = await calculationService.runCalculation(
          _dataController.sheetContent,
        );

        int nVal = result.instrTable.length;
        if (result.errorRoot.newChildren!.isNotEmpty || nVal == 0) {
          return result;
        }

        Map<int, List<SortingRule>> myRules = {};
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
        List<int>? result0 = await service.solveSorting(nVal, myRules);

        if (result0 == null) {
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
        result.rowCount = _dataController.rowCount;
        result.colCount = _dataController.colCount;
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

  void updateRowColCount({
    double? visibleHeight,
    double? visibleWidth,
    bool notify = true,
    bool save = true,
  }) {
    int targetRows = _selectionController.tableViewRows;
    int targetCols = _selectionController.tableViewCols;

    if (visibleHeight != null) {
      _gridController.visibleWindowHeight = visibleHeight;
      targetRows = _dataController.minRows(_gridController.visibleWindowHeight);
    }
    if (visibleWidth != null) {
      _gridController.visibleWindowWidth = visibleWidth;
      targetCols = _dataController.minCols(_gridController.visibleWindowWidth);
    }

    // We access the selection manager via the controller
    // This assumes the controller exposes the way to set these,
    // or we modify the selection model directly via the controller's selection getter.
    if (targetRows != _selectionController.tableViewRows ||
        targetCols != _selectionController.tableViewCols) {
      _selectionController.tableViewRows = targetRows;
      _selectionController.tableViewCols = targetCols;
      if (notify) {
        notifyListeners();
      }
    }
    if (save) {
      _dataController.saveLastSelection(_selectionController.selection);
    }
  }


  Future<void> loadSheetByName(
    String name, {
    bool init = false,
    SelectionModel? lastSelection,
  }) async {
    if (!init) {
      _dataController.lastSelectedCells[_dataController.sheetName] =
          _selectionController.selection;
      _saveSheetDataUseCase.saveAllLastSelected(
        _dataController.lastSelectedCells,
      );
      _saveSheetDataUseCase.saveLastOpenedSheetName(name);
    }

    if (_dataController.availableSheets.contains(name)) {
      if (_dataController.loadedSheetsData.containsKey(name)) {
        _dataController.sheet = _dataController.loadedSheetsData[name]!;
        _selectionController.selection =
            _dataController.lastSelectedCells[name]!;
      } else {
        _dataController.saveExecutors[name] = ManageWaitingTasks<void>();
        try {
          _dataController.sheet = await _getDataUseCase.loadSheet(name);
          if (!init) {
            _selectionController.selection =
                _dataController.lastSelectedCells[name]!;
          }
        } catch (e) {
          logger.e("Error parsing sheet data for $name: $e");
          _dataController.sheet = SheetModel.empty();
          _selectionController.selection = SelectionModel.empty();
        }
      }
    } else {
      _dataController.sheet = SheetModel.empty();
      _selectionController.selection = SelectionModel.empty();
      _dataController.availableSheets.add(name);
      _saveSheetDataUseCase.saveAllSheetNames(_dataController.availableSheets);
      _dataController.saveExecutors[name] = ManageWaitingTasks<void>();
    }

    if (!init) {
      _dataController.saveLastSelection(_selectionController.selection);
    }

    _dataController.loadedSheetsData[name] = _dataController.sheet;
    _dataController.sheetName = name;

    // Trigger Controller updates
    updateRowColCount(
      visibleHeight: _gridController.visibleWindowHeight,
      visibleWidth: _gridController.visibleWindowWidth,
      notify: false,
    );

    _streamController.scrollToOffset(
      x: _selectionController.selection.scrollOffsetX,
      y: _selectionController.selection.scrollOffsetY,
      animate: false,
    );

    saveAndCalculate(save: false);
    notifyListeners();
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
  void commit() {
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

  void stopEditing(bool updateHistory) {
    _selectionController.editingMode = false;
    _dataController.saveLastSelection(_selectionController.selection);
    notifyListeners();
    if (updateHistory && _historyController.currentUpdateHistory != null) {
      saveAndCalculate(updateHistory: true);
    }
    _historyController.discardCurrent();
  }

  void startEditing({String? initialInput}) {
    _selectionController.previousContent = _dataController.getContent(
      _selectionController.primarySelectedCell.x,
      _selectionController.primarySelectedCell.y,
    );
    onChanged(initialInput!);
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
      if (col < _dataController.colCount) {
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
    final data = await Clipboard.getData('text/plain');
    if (data?.text == null) return;
    // if contains "
    if (data!.text!.contains('"')) {
      debugPrint('Paste data contains unsupported characters.');
      return;
    }

    final List<CellUpdate> updates = _parsePasteDataUseCase.pasteText(
      data.text!,
      _selectionController.primarySelectedCell.x,
      _selectionController.primarySelectedCell.y,
    );

    // 2. Update UI & Persist
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
    String prevValue = '';
    if (newValue.isNotEmpty ||
        (row < _dataController.rowCount && col < _dataController.colCount)) {
      if (row >= _dataController.rowCount) {
        final needed = row + 1 - _dataController.rowCount;
        _dataController.sheetContent.table.addAll(
          List.generate(
            needed,
            (_) => List.filled(_dataController.colCount, '', growable: true),
          ),
        );
      }
      _dataController.increaseColumnCount(col);
      prevValue = _dataController.sheetContent.table[row][col];
      _dataController.sheetContent.table[row][col] = newValue;
    }

    // Clean up empty rows/cols at the end
    if (newValue.isEmpty &&
        row < _dataController.rowCount &&
        col < _dataController.colCount &&
        (row == _dataController.rowCount - 1 ||
            col == _dataController.colCount - 1) &&
        prevValue.isNotEmpty) {
      _dataController.decreaseRowCount(row);
      if (col == _dataController.colCount - 1) {
        int colId = col;
        bool canRemove = true;
        while (canRemove && colId >= 0) {
          for (var r = 0; r < _dataController.rowCount; r++) {
            if (_dataController.sheetContent.table[r][colId].isNotEmpty) {
              canRemove = false;
              break;
            }
          }
          if (canRemove) {
            for (var r = 0; r < _dataController.rowCount; r++) {
              _dataController.sheetContent.table[r].removeLast();
            }
            colId--;
          }
        }
      }
    }
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
    if (row >= _dataController.sheet.rowsBottomPos.length &&
        row >= _dataController.rowCount) {
      updateRowColCount(
        visibleHeight: _gridController.visibleWindowHeight,
        visibleWidth: _gridController.visibleWindowWidth,
        notify: false,
      );
      return;
    }

    double heightItNeeds = _dataController.calculateRequiredRowHeight(
      newValue,
      col,
    );

    if (heightItNeeds > GetDefaultSizes.getDefaultRowHeight() &&
        _dataController.sheet.rowsBottomPos.length <= row) {
      int prevRowsBottomPosLength = _dataController.sheet.rowsBottomPos.length;
      _dataController.sheet.rowsBottomPos.addAll(
        List.filled(row + 1 - _dataController.sheet.rowsBottomPos.length, 0),
      );
      for (int i = prevRowsBottomPosLength; i <= row; i++) {
        _dataController.sheet.rowsBottomPos[i] = i == 0
            ? GetDefaultSizes.getDefaultRowHeight()
            : _dataController.sheet.rowsBottomPos[i - 1] +
                  GetDefaultSizes.getDefaultRowHeight();
      }
    }

    if (row < _dataController.sheet.rowsBottomPos.length) {
      if (_dataController.sheet.rowsManuallyAdjustedHeight.length <= row ||
          !_dataController.sheet.rowsManuallyAdjustedHeight[row]) {
        double currentHeight = _dataController.getRowHeight(row);
        if (heightItNeeds < currentHeight) {
          double heightItNeeded = _dataController.calculateRequiredRowHeight(
            prevValue,
            col,
          );
          if (heightItNeeded == currentHeight) {
            double newHeight = heightItNeeds;
            for (int j = 0; j < _dataController.colCount; j++) {
              if (j == col) continue;
              newHeight = max(
                _dataController.calculateRequiredRowHeight(
                  _dataController.sheetContent.table[row][j],
                  j,
                ),
                newHeight,
              );
              if (newHeight == heightItNeeded) break;
            }
            if (newHeight < heightItNeeded) {
              double heightDiff = currentHeight - newHeight;
              for (
                int r = row;
                r < _dataController.sheet.rowsBottomPos.length;
                r++
              ) {
                _dataController.sheet.rowsBottomPos[r] -= heightDiff;
              }
              if (newHeight == GetDefaultSizes.getDefaultRowHeight()) {
                int removeFrom = _dataController.sheet.rowsBottomPos.length;
                for (
                  int r = _dataController.sheet.rowsBottomPos.length - 1;
                  r >= 0;
                  r--
                ) {
                  if (r <
                              _dataController
                                  .sheet
                                  .rowsManuallyAdjustedHeight
                                  .length &&
                          _dataController.sheet.rowsManuallyAdjustedHeight[r] ||
                      _dataController.sheet.rowsBottomPos[r] >
                          (r == 0
                                  ? 0
                                  : _dataController.sheet.rowsBottomPos[r -
                                        1]) +
                              GetDefaultSizes.getDefaultRowHeight()) {
                    break;
                  }
                  removeFrom--;
                }
                _dataController.sheet.rowsBottomPos = _dataController
                    .sheet
                    .rowsBottomPos
                    .sublist(0, removeFrom);
              }
            }
          }
        } else if (heightItNeeds > currentHeight) {
          double heightDiff = heightItNeeds - currentHeight;
          for (
            int r = row;
            r < _dataController.sheet.rowsBottomPos.length;
            r++
          ) {
            _dataController.sheet.rowsBottomPos[r] =
                _dataController.sheet.rowsBottomPos[r] + heightDiff;
          }
        }
      }
    } else if (heightItNeeds == GetDefaultSizes.getDefaultRowHeight() &&
        row == _dataController.sheet.rowsBottomPos.length - 1) {
      int i = row;
      while (_dataController.sheet.rowsBottomPos[i] ==
              GetDefaultSizes.getDefaultRowHeight() &&
          row > 0) {
        _dataController.sheet.rowsBottomPos.removeLast();
        i--;
      }
    }
    updateRowColCount(
      visibleHeight: _gridController.visibleWindowHeight,
      visibleWidth: _gridController.visibleWindowWidth,
      notify: false,
    );
  }


  void selectAll() {
    _selectionController.selectedCells.clear();
    for (int r = 0; r < _dataController.rowCount; r++) {
      for (int c = 0; c < _dataController.colCount; c++) {
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

  Future<void> init() async {
    await _saveSheetDataUseCase.clearAllData();
    await _saveSheetDataUseCase.initialize();
    try {
      _dataController.sheetName = await _getDataUseCase
          .getLastOpenedSheetName();
    } catch (e) {
      await _saveSheetDataUseCase.saveLastOpenedSheetName(
        _dataController.sheetName,
      );
    }
    try {
      _selectionController.selection = await _getDataUseCase.getLastSelection();
    } catch (e) {
      _selectionController.selection = SelectionModel.empty();
      await _dataController.saveLastSelection(_selectionController.selection);
    }

    _dataController.availableSheets = await _getDataUseCase.getAllSheetNames();
    if (!CheckValidStrings.isValidSheetName(_dataController.sheetName)) {
      if (_dataController.availableSheets.isNotEmpty) {
        _dataController.sheetName = _dataController.availableSheets[0];
      } else {
        _dataController.sheetName = SpreadsheetConstants.defaultSheetName;
      }
      _saveSheetDataUseCase.saveLastOpenedSheetName(_dataController.sheetName);
    }
    bool availableSheetsChanged = false;
    if (!_dataController.availableSheets.contains(_dataController.sheetName)) {
      _dataController.availableSheets.add(_dataController.sheetName);
      availableSheetsChanged = true;
      debugPrint(
        "Last opened sheet ${_dataController.sheetName} not found in available sheets, adding it.",
      );
    }
    _dataController.lastSelectedCells = await _getDataUseCase
        .getAllLastSelected();
    bool changed = false;
    for (var name in _dataController.availableSheets) {
      if (!_dataController.lastSelectedCells.containsKey(name)) {
        _dataController.lastSelectedCells[name] = SelectionModel.empty();
        changed = true;
        debugPrint(
          "No last selected cell for sheet $name, defaulting to (0,0)",
        );
      }
    }
    if (changed) {
      _saveSheetDataUseCase.saveAllLastSelected(
        _dataController.lastSelectedCells,
      );
    }
    for (var name in _dataController.lastSelectedCells.keys) {
      if (!_dataController.availableSheets.contains(name)) {
        _dataController.availableSheets.add(name);
        availableSheetsChanged = true;
      }
    }
    if (availableSheetsChanged) {
      _saveSheetDataUseCase.saveAllSheetNames(_dataController.availableSheets);
    }

    loadSheetByName(_dataController.sheetName, init: true);
  }

  KeyEventResult handleKeyboard(BuildContext context, KeyEvent event) =>
      _keyboardDelegate.handle(context, event);

  KeyEventResult handleKeyboard(
    BuildContext context,
    KeyEvent event) {
    if (editingMode) {
      return KeyEventResult.ignored;
    }

    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }

    final keyLabel = event.logicalKey.keyLabel.toLowerCase();
    final logicalKey = event.logicalKey;
    final isControl =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    final isAlt = HardwareKeyboard.instance.isAltPressed;

    if (logicalKey == LogicalKeyboardKey.enter ||
        logicalKey == LogicalKeyboardKey.numpadEnter) {
      startEditing();
      return KeyEventResult.handled;
    }

    if (logicalKey == LogicalKeyboardKey.arrowUp) {
      setPrimarySelection(
        max(primarySelectedCell.x - 1, 0),
        primarySelectedCell.y,
        false,
        true,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
      setPrimarySelection(
        primarySelectedCell.x + 1,
        primarySelectedCell.y,
        false,
        true,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
      setPrimarySelection(
        primarySelectedCell.x,
        max(0, primarySelectedCell.y - 1),
        false,
        true,
      );
      return KeyEventResult.handled;
    } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
      setPrimarySelection(
        primarySelectedCell.x,
        primarySelectedCell.y + 1,
        false,
        true,
      );
      return KeyEventResult.handled;
    }

    if (isControl && keyLabel == 'c') {
      copySelectionToClipboard();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selection copied'),
          duration: Duration(milliseconds: 500),
        ),
      );
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'v') {
      pasteSelection();
      return KeyEventResult.handled;
    } else if (keyLabel == 'delete') {
      delete();
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'z') {
      undo();
      return KeyEventResult.handled;
    } else if (isControl && keyLabel == 'y') {
      redo();
      return KeyEventResult.handled;
    }

    final bool isPrintable =
        event.character != null &&
        event.character!.isNotEmpty &&
        !isControl &&
        !isAlt &&
        logicalKey.keyId > 32;

    if (isPrintable) {
      startEditing(initialInput: event.character);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
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
      await Clipboard.setData(
        ClipboardData(
          text: _dataController.getContent(
            _selectionController.primarySelectedCell.x,
            _selectionController.primarySelectedCell.y,
          ),
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
    await Clipboard.setData(ClipboardData(text: text));
  }

}
