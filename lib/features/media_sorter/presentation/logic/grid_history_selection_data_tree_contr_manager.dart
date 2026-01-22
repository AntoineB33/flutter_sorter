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
import 'package:trying_flutter/features/media_sorter/domain/usecases/layout_calculator.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/save_sheet_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/grid_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/history_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/selection_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/sheet_data_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/tree_controller.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/check_valid_strings.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/get_default_sizes.dart';
import '../../domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart'; // Import AnalysisResult
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/utils/logger.dart';
import 'package:trying_flutter/features/media_sorter/presentation/controllers/spreadsheet_stream_controller.dart';

class GridHistorySelectionDataTreeContrManager extends ChangeNotifier {
  // --- dependencies ---
  final GridController _gridController;
  final HistoryController _historyController;
  final SelectionController _selectionController;
  final SheetDataController _dataController;
  final TreeController _treeController;
  final SpreadsheetStreamController _streamController;
  
  // --- usecases ---
  final SpreadsheetLayoutCalculator _layoutCalculator =
      SpreadsheetLayoutCalculator();
  final SaveSheetDataUseCase _saveSheetDataUseCase = SaveSheetDataUseCase(SheetRepositoryImpl(FileSheetLocalDataSource()));
  final GetSheetDataUseCase _getDataUseCase = GetSheetDataUseCase(SheetRepositoryImpl(FileSheetLocalDataSource()));
  final CalculationService calculationService = CalculationService();
  final ParsePasteDataUseCase _parsePasteDataUseCase = ParsePasteDataUseCase();

  // --- utils ---
  final GetNames _getNames = GetNames();
  final GetDefaultSizes _getDefaultSizes = GetDefaultSizes();
  final CheckValidStrings _checkValidStrings = CheckValidStrings();

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
  Stream<SpreadsheetScrollRequest> get scrollStream => _streamController.scrollStream;
  bool get editingMode => _selectionController.editingMode;
  int get tableViewRows => _selectionController.tableViewRows;
  int get tableViewCols => _selectionController.tableViewCols;
  Point<int> get primarySelectedCell => _selectionController.primarySelectedCell;
  String get previousContent => _selectionController.selection.previousContent;

  // --- setters ---
  set sheetName(String value) {
    _dataController.sheetName = value;
  }

  GridHistorySelectionDataTreeContrManager(
    this._gridController,
    this._historyController,
    this._selectionController,
    this._dataController,
    this._treeController,
    this._streamController,
  ) {
    init();
  }

  void increaseColumnCount(int col) {
    if (col >= _dataController.colCount) {
      final needed = col + 1 - _dataController.colCount;
      for (var r = 0; r < _dataController.rowCount; r++) {
        _dataController.sheetContent.table[r].addAll(
          List.filled(needed, '', growable: true),
        );
      }
      _dataController.sheetContent.columnTypes.addAll(
        List.filled(needed, ColumnType.attributes),
      );
    }
  }

  void decreaseRowCount(int row) {
    if (row == _dataController.rowCount - 1) {
      while (row >= 0 &&
          !_dataController.sheetContent.table[row].any(
            (cell) => cell.isNotEmpty,
          )) {
        _dataController.sheetContent.table.removeLast();
        row--;
      }
    }
  }

  double getRowHeight(int row) {
    if (row < _dataController.sheet.rowsBottomPos.length) {
      if (row == 0) {
        return _dataController.sheet.rowsBottomPos[0];
      } else {
        return _dataController.sheet.rowsBottomPos[row] -
            _dataController.sheet.rowsBottomPos[row - 1];
      }
    }
    return _getDefaultSizes.getDefaultRowHeight();
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

    double heightItNeeds = calculateRequiredRowHeight(newValue, col);

    if (heightItNeeds > _getDefaultSizes.getDefaultRowHeight() &&
        _dataController.sheet.rowsBottomPos.length <= row) {
      int prevRowsBottomPosLength = _dataController.sheet.rowsBottomPos.length;
      _dataController.sheet.rowsBottomPos.addAll(
        List.filled(row + 1 - _dataController.sheet.rowsBottomPos.length, 0),
      );
      for (int i = prevRowsBottomPosLength; i <= row; i++) {
        _dataController.sheet.rowsBottomPos[i] = i == 0
            ? _getDefaultSizes.getDefaultRowHeight()
            : _dataController.sheet.rowsBottomPos[i - 1] +
                  _getDefaultSizes.getDefaultRowHeight();
      }
    }

    if (row < _dataController.sheet.rowsBottomPos.length) {
      if (_dataController.sheet.rowsManuallyAdjustedHeight.length <= row ||
          !_dataController.sheet.rowsManuallyAdjustedHeight[row]) {
        double currentHeight = getRowHeight(row);
        if (heightItNeeds < currentHeight) {
          double heightItNeeded = calculateRequiredRowHeight(prevValue, col);
          if (heightItNeeded == currentHeight) {
            double newHeight = heightItNeeds;
            for (int j = 0; j < _dataController.colCount; j++) {
              if (j == col) continue;
              newHeight = max(
                calculateRequiredRowHeight(
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
              if (newHeight == _getDefaultSizes.getDefaultRowHeight()) {
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
                              _getDefaultSizes.getDefaultRowHeight()) {
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
    } else if (heightItNeeds == _getDefaultSizes.getDefaultRowHeight() &&
        row == _dataController.sheet.rowsBottomPos.length - 1) {
      int i = row;
      while (_dataController.sheet.rowsBottomPos[i] ==
              _getDefaultSizes.getDefaultRowHeight() &&
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

  void scroll(ScrollMetrics metrics, BuildContext context) {
    final double visibleEdge = metrics.pixels + metrics.viewportDimension;
    if (metrics.axis == Axis.vertical) {
      _selectionController.selection.scrollOffsetY = metrics.pixels;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          updateRowColCount(
            visibleHeight: visibleEdge - sheet.colHeaderHeight
          );
        }
      });
    } else if (metrics.axis == Axis.horizontal) {
      _selectionController.selection.scrollOffsetX = metrics.pixels;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          updateRowColCount(
            visibleWidth: visibleEdge - sheet.rowHeaderWidth
          );
        }
      });
    }
  }

  void updateRowColCount({
    double? visibleHeight,
    double? visibleWidth,
    bool notify = true,
    bool save = true
  }) {
    int targetRows = _selectionController.tableViewRows;
    int targetCols = _selectionController.tableViewCols;

    if (visibleHeight != null) {
      _gridController.visibleWindowHeight = visibleHeight;
      targetRows = minRows(_gridController.visibleWindowHeight);
    }
    if (visibleWidth != null) {
      _gridController.visibleWindowWidth = visibleWidth;
      targetCols = minCols(_gridController.visibleWindowWidth);
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
      saveLastSelection(_selectionController.selection);
    }
  }

  double getTargetTop(int row) {
    if (row <= 0) return 0.0;
    final int nbKnownBottomPos = _dataController.sheet.rowsBottomPos.length;
    var rowsBottomPos = _dataController.sheet.rowsBottomPos;
    final int tableHeight = nbKnownBottomPos == 0
        ? 0
        : rowsBottomPos.last.toInt();
    final double targetTop = row - 1 < nbKnownBottomPos
        ? rowsBottomPos[row - 1].toDouble()
        : tableHeight +
              (row - nbKnownBottomPos) * _getDefaultSizes.getDefaultRowHeight();
    return targetTop;
  }

  double getTargetLeft(int col) {
    if (col <= 0) return 0.0;
    final int nbKnownRightPos = _dataController.sheet.colRightPos.length;
    var columnsRightPos = _dataController.sheet.colRightPos;
    final int tableWidth = nbKnownRightPos == 0
        ? 0
        : columnsRightPos.last.toInt();
    final double targetRight = col - 1 < nbKnownRightPos
        ? columnsRightPos[col - 1].toDouble()
        : tableWidth + (col - nbKnownRightPos) * _getDefaultSizes.getDefaultCellWidth();
    return targetRight;
  }

  int minRows(double height) {
    double tableHeight = getTargetTop(_dataController.rowCount - 1);
    if (height >= tableHeight) {
      return _dataController.sheet.rowsBottomPos.length +
          (height -
                  getTargetTop(
                    _dataController.sheet.rowsBottomPos.length - 1,
                  )) ~/
              _getDefaultSizes.getDefaultRowHeight() +
          1;
    }
    return _dataController.rowCount;
  }

  int minCols(double width) {
    double tableWidth = getTargetLeft(_dataController.colCount - 1);
    if (width >= tableWidth) {
      return _dataController.sheet.colRightPos.length +
          (width -
                  getTargetLeft(
                    _dataController.sheet.colRightPos.length - 1,
                  )) ~/
              _getDefaultSizes.getDefaultCellWidth() +
          1;
    }
    return _dataController.colCount;
  }

  double getColumnWidth(int col) {
    return getTargetLeft(col + 1) - getTargetLeft(col);
  }

  double calculateRequiredRowHeight(String text, int colId) {
    final double availableWidth =
        getColumnWidth(colId) - PageConstants.horizontalPadding;
    return _layoutCalculator.calculateRowHeight(text, availableWidth);
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

  void keepOnlyPrim() {
    _selectionController.selectedCells.clear();
    saveLastSelection(_selectionController.selection);
    notifyListeners();
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

  bool isPrimarySelectedCell(int row, int col) {
    return row == _selectionController.primarySelectedCell.x &&
        col == _selectionController.primarySelectedCell.y;
  }

  Future<void> init() async {
    // await _saveSheetDataUseCase.clearAllData();
    await _saveSheetDataUseCase.initialize();
    try {
      _dataController.sheetName = await _getDataUseCase.getLastOpenedSheetName();
    } catch (e) {
      await _saveSheetDataUseCase.saveLastOpenedSheetName(_dataController.sheetName);
    }
    try {
      _selectionController.selection = await _getDataUseCase.getLastSelection();
    } catch (e) {
      _selectionController.selection = SelectionModel.empty();
      await saveLastSelection(_selectionController.selection);
    }

    _dataController.availableSheets = await _getDataUseCase.getAllSheetNames();
    if (!_checkValidStrings.isValidSheetName(_dataController.sheetName)) {
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
    _dataController.lastSelectedCells = await _getDataUseCase.getAllLastSelected();
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
      _saveSheetDataUseCase.saveAllLastSelected(_dataController.lastSelectedCells);
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

    loadSheetByName(_dataController.sheetName, init: true, );
  }

  Future<void> loadSheetByName(String name, {bool init = false, SelectionModel? lastSelection}) async {
    if (!init) {
      _dataController.lastSelectedCells[_dataController.sheetName] = _selectionController.selection;
      _saveSheetDataUseCase.saveAllLastSelected(_dataController.lastSelectedCells);
      _saveSheetDataUseCase.saveLastOpenedSheetName(name);
    }

    if  (_dataController.availableSheets.contains(name)) {
      if (_dataController.loadedSheetsData.containsKey(name)) {
        _dataController.sheet = _dataController.loadedSheetsData[name]!;
        _selectionController.selection = _dataController.lastSelectedCells[name]!;
      } else {
        _dataController.saveExecutors[name] = ManageWaitingTasks<void>();
        try {
          _dataController.sheet = await _getDataUseCase.loadSheet(name);
          if (!init) {
            _selectionController.selection = _dataController.lastSelectedCells[name]!;
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
      saveLastSelection(_selectionController.selection);
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

  Future<void> saveLastSelection(SelectionModel selection) async {
    _dataController.saveLastSelectionExecutor.execute(() async {
      await _saveSheetDataUseCase.saveLastSelection(selection);
      await Future.delayed(Duration(milliseconds: SpreadsheetConstants.saveDelayMs));
    });
  }

  // Content Access
  String getContent(int row, int col) {
    if (row < _dataController.rowCount && col < _dataController.colCount) {
      return _dataController.sheetContent.table[row][col];
    }
    return '';
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
    if (newValue.isNotEmpty || (row < _dataController.rowCount && col < _dataController.colCount)) {
      if (row >= _dataController.rowCount) {
        final needed = row + 1 - _dataController.rowCount;
        _dataController.sheetContent.table.addAll(
          List.generate(
            needed,
            (_) => List.filled(_dataController.colCount, '', growable: true),
          ),
        );
      }
      increaseColumnCount(col);
      prevValue = _dataController.sheetContent.table[row][col];
      _dataController.sheetContent.table[row][col] = newValue;
    }

    // Clean up empty rows/cols at the end
    if (newValue.isEmpty &&
        row < _dataController.rowCount &&
        col < _dataController.colCount &&
        (row == _dataController.rowCount - 1 || col == _dataController.colCount - 1) &&
        prevValue.isNotEmpty) {
      decreaseRowCount(row);
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

  void applyDefaultColumnSequence() {
    setColumnType(0, ColumnType.names);
    setColumnType(1, ColumnType.dependencies);
    setColumnType(2, ColumnType.dependencies);
    setColumnType(3, ColumnType.dependencies);
    setColumnType(7, ColumnType.urls);
    setColumnType(8, ColumnType.dependencies);
  }

  bool isCellSelected(int row, int col) {
    return _selectionController.selectedCells.any(
      (cell) => cell.x == row && cell.y == col,
    );
  }

  void startEditing({String? initialInput}) {
    _selectionController.previousContent = getContent(_selectionController.primarySelectedCell.x, _selectionController.primarySelectedCell.y);
    onChanged(initialInput!);
    _selectionController.editingMode = true;
    saveLastSelection(_selectionController.selection);
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

  void stopEditing(bool updateHistory) {
    _selectionController.editingMode = false;
    saveLastSelection(_selectionController.selection);
    notifyListeners();
    if (updateHistory && _historyController.currentUpdateHistory != null) {
      saveAndCalculate(updateHistory: true);
    }
    _historyController.discardCurrent();
  }

  bool isCellEditing(int row, int col) =>
      _selectionController.editingMode &&
      _selectionController.primarySelectedCell.x == row &&
      _selectionController.primarySelectedCell.y == col;
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
          text: getContent(
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
        rowData.add(getContent(r, c));
      }
      buffer.write(rowData.join('\t')); // Tab separated for Excel compat
      if (r < endRow) buffer.write('\n');
    }

    final text = buffer.toString();
    await Clipboard.setData(ClipboardData(text: text));
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
          _dataController.sheetContent.table,
          _dataController.sheetContent.columnTypes,
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
    saveLastSelection(_selectionController.selection);

    // Update Mentions
    if (updateMentions) {
      _treeController.mentionsRoot.newChildren = null;
      _treeController.mentionsRoot.rowId = row;
      _treeController.mentionsRoot.colId = col;
      populateTree([_treeController.mentionsRoot]);
    }

    // Request scroll to visible
    if (scrollTo) {
      _streamController.triggerScrollTo(row, col);
    }
    notifyListeners();
  }

  void populateCellNode(NodeStruct node, bool populateChildren) {
    int rowId = node.rowId!;
    int colId = node.colId!;
    node.cellsToSelect = node.cells;

    if (rowId >= _dataController.rowCount || colId >= _dataController.colCount) {
      return;
    }

    if (node.message == null) {
      if (node.instruction == SpreadsheetConstants.selectionMsg) {
        node.message =
            '${_getNames.getColumnLabel(colId)}$rowId selected: ${getContent(rowId, colId)}';
      } else {
        node.message =
            '${_getNames.getColumnLabel(colId)}$rowId: ${getContent(rowId, colId)}';
      }
    }

    if (node.defaultOnTap) {
      node.onTap = (n) {
        setPrimarySelection(node.rowId!, node.colId!, false, false);
      };
      node.defaultOnTap = false;
    }

    if (!populateChildren) return;

    node.newChildren = [];

    // Simple column types (names, files, urls) don't need deep analysis data
    if (_dataController.sheetContent.columnTypes[colId] == ColumnType.names ||
        _dataController.sheetContent.columnTypes[colId] ==
            ColumnType.filePath ||
        _dataController.sheetContent.columnTypes[colId] == ColumnType.urls) {
      node.newChildren!.add(
        NodeStruct(
          message: _dataController.sheetContent.table[rowId][colId],
          att: Attribute.row(rowId),
        ),
      );
      return;
    }

    // Use LOCAL _lastAnalysis state instead of _controller lookup
    if (_treeController.tableToAtt.length <= rowId ||
        _treeController.tableToAtt[rowId].length <= colId) {
      return;
    }

    for (Attribute att in _treeController.tableToAtt[rowId][colId]) {
      node.newChildren!.add(NodeStruct(att: att));
    }
  }

  void populateNodeDefault(NodeStruct node, bool populateChildren) {
    if (node.rowId != null) {
      if (node.colId != null) {
        if (node.name != null) {
          throw UnimplementedError(
            "CellWithName with name, row and col not implemented",
          );
        } else {
          populateCellNode(node, populateChildren);
        }
      } else {
        if (node.name != null) {
          throw UnimplementedError(
            "CellWithName with name and row not implemented",
          );
        } else {
          populateRowNode(node, populateChildren);
        }
      }
    } else {
      if (node.colId != null) {
        if (node.name != null) {
          populateAttributeNode(node, populateChildren);
        } else {
          populateColumnNode(node, populateChildren);
        }
      } else {
        if (node.name != null) {
          if (_treeController.attToCol.containsKey(node.name)) {
            if (_treeController.attToCol[node.name]! !=
                [SpreadsheetConstants.notUsedCst]) {
              node.newChildren!.add(
                NodeStruct(
                  instruction: SpreadsheetConstants.attToRefFromDepCol,
                  name: node.name,
                ),
              );
              node.newChildren!.add(
                NodeStruct(
                  instruction: SpreadsheetConstants.attToCol,
                  name: node.name,
                ),
              );
            } else {
              _treeController.populateAttToRefFromDepColNode(
                node,
                populateChildren,
              );
            }
          } else {
            debugPrint(
              "populateNode: Unhandled CellWithName with name only: ${node.name}",
            );
          }
        }
      }
    }
    // ... (Keep existing defaultOnTap logic, but use _controller for actions only)
    if (node.defaultOnTap) {
      if (node.cellsToSelect == null) {
        node.cellsToSelect = node.cells;
        if (node.cellsToSelect == null || node.cellsToSelect!.isEmpty) {
          List<Cell> cells = [];
          for (final child in node.newChildren ?? []) {
            if (child.rowId != null) {
              if (child.colId != null) {
                cells.add(Cell(rowId: child.rowId!, colId: child.colId!));
              } else {
                cells.add(Cell(rowId: child.rowId!, colId: 0));
              }
            } else if (child.colId != null) {
              cells.add(Cell(rowId: 0, colId: child.colId!));
            }
          }
          node.cellsToSelect = cells;
        }
      }
      node.onTap = (n) {
        if (node.cellsToSelect == null || node.cellsToSelect!.isEmpty) {
          return;
        }
        int found = -1;
        for (int i = 0; i < node.cellsToSelect!.length; i++) {
          final child = node.cellsToSelect![i];
          if (_selectionController.primarySelectedCell.x == child.rowId &&
              _selectionController.primarySelectedCell.y == child.colId) {
            found = i;
            break;
          }
        }
        if (found == -1) {
          setPrimarySelection(
            node.cellsToSelect![0].rowId,
            node.cellsToSelect![0].colId,
            false,
            false,
          );
        } else {
          setPrimarySelection(
            node.cellsToSelect![(found + 1) % node.cellsToSelect!.length].rowId,
            node.cellsToSelect![(found + 1) % node.cellsToSelect!.length].colId,
            false,
            false,
          );
        }
      };
      node.defaultOnTap = false;
    }
  }

  void populateNode(NodeStruct node) {
    bool populateChildren = node.newChildren == null;
    if (populateChildren) {
      node.newChildren = [];
    }
    switch (node.instruction) {
      case SpreadsheetConstants.refFromAttColMsg:
        if (populateChildren) {
          for (int pointerRowId
              in _treeController.attToRefFromAttColToCol[node.att]!.keys) {
            node.newChildren!.add(NodeStruct(rowId: pointerRowId));
          }
        }
        break;
      case SpreadsheetConstants.refFromDepColMsg:
        if (populateChildren) {
          for (int pointerRowId
              in _treeController.attToRefFromDepColToCol[node.att]!.keys) {
            node.newChildren!.add(NodeStruct(rowId: pointerRowId));
          }
        }
        break;
      case SpreadsheetConstants.nodeAttributeMsg:
        populateAttributeNode(node, populateChildren);
        break;
      case SpreadsheetConstants.cycleDetected:
        node.onTap = (n) {
          int found = -1;
          for (int i = 0; i < n.newChildren!.length; i++) {
            final child = n.newChildren![i];
            if (_selectionController.primarySelectedCell.x == child.rowId) {
              found = i;
              break;
            }
          }
          if (found == -1) {
            setPrimarySelection(
              n.newChildren![0].rowId!,
              n.newChildren![0].colId!,
              false,
              false,
            );
          } else {
            setPrimarySelection(
              n.newChildren![(found + 1) % n.newChildren!.length].rowId!,
              n.newChildren![(found + 1) % n.newChildren!.length].colId!,
              false,
              false,
            );
          }
        };
        break;
      case SpreadsheetConstants.attToRefFromDepCol:
        _treeController.populateAttToRefFromDepColNode(node, populateChildren);
        break;
      default:
        populateNodeDefault(node, populateChildren);
        break;
    }
  }

  void populateAttributeNode(NodeStruct node, bool populateChildren) {
    if (populateChildren) {
      if (_treeController.attToRefFromAttColToCol.containsKey(node.att)) {
        node.newChildren!.add(
          NodeStruct(
            instruction: SpreadsheetConstants.refFromAttColMsg,
            att: node.att,
          ),
        );
      } else {
        node.newChildren!.add(
          NodeStruct(message: 'No references from attribute columns found'),
        );
      }
      if (_treeController.attToRefFromDepColToCol.containsKey(node.att)) {
        node.newChildren!.add(
          NodeStruct(
            instruction: SpreadsheetConstants.refFromDepColMsg,
            att: node.att,
          ),
        );
      } else {
        node.newChildren!.add(
          NodeStruct(message: 'No references from dependence columns found'),
        );
      }
    }

    node.message ??= node.name;

    if (node.defaultOnTap) {
      node.onTap = (n) {
        if (node.rowId != null) {
          setPrimarySelection(node.rowId!, 0, false, false);
          return;
        }

        List<Cell> cells = [];
        List<MapEntry> entries = [];

        if (node.colId != SpreadsheetConstants.notUsedCst) {
          entries = _treeController.attToRefFromAttColToCol[node.att]!.entries
              .toList();
        }

        if (node.instruction !=
            SpreadsheetConstants.moveToUniqueMentionSprawlCol) {
          entries.addAll(
            _treeController.attToRefFromDepColToCol[node.att]!.entries.toList(),
          );
        }

        for (final MapEntry(key: rowId, value: colIds) in entries) {
          for (final colId in colIds) {
            cells.add(Cell(rowId: rowId, colId: colId));
          }
        }

        // ... (Selection logic remains the same, invoking _controller.setPrimarySelection)
        _handleSelectionLogic(node, cells);
      };
      node.defaultOnTap = false;
    }
  }

  // Extracted selection logic to keep populateAttributeNode cleaner
  void _handleSelectionLogic(NodeStruct node, List<Cell> cells) {
    int found = -1;
    for (int i = 0; i < cells.length; i++) {
      final child = cells[i];
      if (_selectionController.primarySelectedCell.x == child.rowId &&
          _selectionController.primarySelectedCell.y == child.colId) {
        found = i;
        break;
      }
    }

    int index = (found == -1) ? 0 : (found + 1) % cells.length;
    setPrimarySelection(
      cells[index].rowId,
      cells[index].colId,
      false,
      false,
    );
  }

  void populateRowNode(NodeStruct node, bool populateChildren) {
    int rowId = node.rowId!;
    node.message ??= _getNames.getRowName(
      _treeController.nameIndexes,
      _treeController.tableToAtt,
      rowId,
    );
    if (!populateChildren) return;

    List<NodeStruct> rowCells = [];
    for (int colId = 0; colId < _dataController.colCount; colId++) {
      if (_dataController.sheetContent.table[rowId][colId].isNotEmpty) {
        rowCells.add(
          NodeStruct(
            cell: Cell(rowId: rowId, colId: colId),
          ),
        );
      }
    }

    if (rowCells.isNotEmpty) {
      node.newChildren!.add(
        NodeStruct(message: 'Content of the row', newChildren: rowCells),
      );
    }
    populateAttributeNode(node, true);
  }

  void populateColumnNode(NodeStruct node, bool populateChildren) {
    node.message ??= node.colId == -1
        ? "Rows"
        : 'Column ${_getNames.getColumnLabel(node.colId!)} "${_dataController.sheetContent.table[0][node.colId!]}"';
    if (!populateChildren) return;

    if (_treeController.colToAtt.containsKey(node.colId)) {
      for (final attCol in _treeController.colToAtt[node.colId]!) {
        node.newChildren!.add(NodeStruct(att: attCol));
      }
    }
  }

  void populateTree(List<NodeStruct> roots) {
    if (_treeController.noResult) return;

    for (final root in roots) {
      var stack = [root];
      while (stack.isNotEmpty) {
        var node = stack.removeLast();
        populateNode(node);
        if (node.isExpanded) {
          for (int i = 0; i < node.children.length; i++) {
            var obj = node.children[i];
            if (!obj.isExpanded) {
              break;
            }
            for (int j = 0; j < node.newChildren!.length; j++) {
              var newObj = node.newChildren![j];
              if (!newObj.isExpanded && obj == newObj) {
                newObj.isExpanded = true;
                break;
              }
            }
          }
          for (final child in node.children) {
            child.isExpanded = child.startOpen || child.isExpanded;
          }
          if (node.isExpanded) {
            for (final child in node.newChildren!) {
              stack.add(child);
            }
          }
        }
        node.children = node.newChildren!;
      }
    }
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
    populateTree([
      result.errorRoot,
      result.warningRoot,
      _treeController.mentionsRoot,
      _treeController.searchRoot,
      result.categoriesRoot,
      result.distPairsRoot,
    ]);
  }

  // Method to allow Controller to toggle expansion
  void toggleNodeExpansion(NodeStruct node, bool isExpanded) {
    node.isExpanded = isExpanded;
    for (NodeStruct child in node.newChildren ?? []) {
      child.isExpanded = false;
    }
    populateTree([node]);
    notifyListeners();
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
      updateCell(
        update.row,
        update.col,
        update.value,
        keepPrevious: true,
      );
    }
    notifyListeners();
    saveAndCalculate(updateHistory: true);
  }

  void setColumnType(int col, ColumnType type, {bool updateHistory = true}) {
    if (updateHistory) {
      _historyController.recordColumnTypeChange(col, _getNames.getColumnType(_dataController.sheetContent, col), type);
    }
    if (type == ColumnType.attributes) {
      if (col < _dataController.colCount) {
        _dataController.sheetContent.columnTypes[col] = type;
        if (col == _dataController.sheetContent.columnTypes.length - 1) {
          while (col > 0) {
            col--;
            if (_dataController.sheetContent.columnTypes[col] != ColumnType.attributes) {
              break;
            }
          }
          _dataController.sheetContent.columnTypes = _dataController.sheetContent.columnTypes.sublist(
            0,
            col + 1,
          );
        }
      }
    } else {
      increaseColumnCount(col);
      _dataController.sheetContent.columnTypes[col] = type;
    }
    notifyListeners();
    saveAndCalculate(updateHistory: true);
  }
}
