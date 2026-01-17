import 'dart:async';
import 'dart:math';
import 'dart:collection';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import '../../domain/usecases/get_sheet_data_usecase.dart';
import '../../domain/usecases/save_sheet_data_usecase.dart';
import '../../domain/entities/column_type.dart';
import '../../domain/usecases/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import '../../domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/instr_struct.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/tree_manager.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/selection_manager.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/clipboard_manager.dart';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/mixins/get_names.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/layout_calculator.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/history_manager.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/calculate_usecase.dart';
// Add the import for the new manager
import 'package:trying_flutter/features/media_sorter/presentation/logic/sheet_data_manager.dart';

class SpreadsheetScrollRequest {
  final Point<int>? cell;
  final double? offsetX;
  final double? offsetY;
  final bool animate;

  SpreadsheetScrollRequest.toCell(this.cell) 
      : offsetX = null, offsetY = null, animate = true;

  SpreadsheetScrollRequest.toOffset({this.offsetX, this.offsetY, this.animate = false}) 
      : cell = null;
}

class SpreadsheetController extends ChangeNotifier with GetNames {
  int saveDelayMs = 500;

  late final TreeManager _treeManager;
  late final SelectionManager _selectionManager;
  late final ClipboardManager _clipboardManager;
  late final HistoryManager _historyManager;
  late final SheetDataManager _dataManager;

  // Proxy getters for DataManager properties to maintain API compatibility
  SheetModel get sheet => _dataManager.sheet;
  String get sheetName => _dataManager.sheetName;
  List<String> get availableSheets => _dataManager.availableSheets;
  Map<String, SheetModel> get loadedSheetsData => _dataManager.loadedSheetsData;
  Map<String, SelectionModel> get lastSelectedCells => _dataManager.lastSelectedCells;

  @override
  get columnTypes => sheet.columnTypes;

  // --- Scroll Stream Controller ---
  final StreamController<SpreadsheetScrollRequest> _scrollController =
      StreamController<SpreadsheetScrollRequest>.broadcast();
  Stream<SpreadsheetScrollRequest> get scrollStream => _scrollController.stream;
  double visibleWindowHeight = 0.0;
  double visibleWindowWidth = 0.0;

  final SpreadsheetLayoutCalculator _layoutCalculator =
      SpreadsheetLayoutCalculator();
  CalculationService calculationService = CalculationService();
  
  final ManageWaitingTasks<AnalysisResult> _calculateExecutor =
      ManageWaitingTasks<AnalysisResult>();
  AnalysisResult analysisResult = AnalysisResult();
  bool calculatedOnce = false;

  // Dimensions
  bool _isLoading = false;

  int all = SpreadsheetConstants.all;

  final NodeStruct mentionsRoot = NodeStruct(
    instruction: SpreadsheetConstants.selectionMsg,
  );
  final NodeStruct searchRoot = NodeStruct(
    instruction: SpreadsheetConstants.searchMsg,
  );

  /// 2D table of attribute identifiers (row index or name)
  /// mentioned in each cell.
  @override
  List<List<HashSet<Attribute>>> tableToAtt = [];
  Map<String, Cell> names = {};
  Map<String, List<int>> attToCol = {};
  @override
  List<int> nameIndexes = [];
  List<int> pathIndexes = [];

  /// Maps attribute identifiers (row index or name)
  /// to a map of pointers (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  Map<Attribute, Map<int, Cols>> attToRefFromAttColToCol = {};
  Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol = {};
  Map<int, Map<Attribute, int>> rowToAtt = {};

  /// Maps attribute identifiers (row index or name)
  /// to a map of mentioners (row index) to the column index
  Map<Attribute, Map<int, List<int>>> toMentioners = {};
  List<Map<InstrStruct, Cell>> instrTable = [];
  Map<int, HashSet<Attribute>> colToAtt = {};

  SelectionModel get selection => _selectionManager.selection;

  SpreadsheetController({
    required GetSheetDataUseCase getDataUseCase,
    required SaveSheetDataUseCase saveSheetDataUseCase,
    required ParsePasteDataUseCase parsePasteDataUseCase,
  }) {
    _treeManager = TreeManager(this);
    _selectionManager = SelectionManager(this);
    _clipboardManager = ClipboardManager(this);
    _historyManager = HistoryManager(this);
    _dataManager = SheetDataManager(
      this,
      getDataUseCase: getDataUseCase,
      saveSheetDataUseCase: saveSheetDataUseCase,
    );
    init();
  }

  void discardCurrent() {
    _historyManager.discardCurrent();
  }

  bool isValidSheetName(String name) {
    return _dataManager.isValidSheetName(name);
  }

  // --- Initialization Logic ---
  Future<void> init() async {
    await _dataManager.init();
  }

  @override
  void dispose() {
    _scrollController.close();
    super.dispose();
  }

  // Getters
  bool get isLoading => _isLoading;
  int get rowCount => sheet.table.length;
  @override
  int get colCount => rowCount > 0 ? sheet.table[0].length : 0;

  // Internal helper for DataManager to update loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Internal helper for DataManager to set selection
  void setSelection(SelectionModel newSelection) {
    _selectionManager.selection = newSelection;
  }

  Future<void> loadSheetByName(String name, {bool init = false}) async {
    await _dataManager.loadSheetByName(name, init: init);
  }

  // --- Content Access ---
  String getContent(int row, int col) {
    if (row < rowCount && col < colCount) {
      return sheet.table[row][col];
    }
    return '';
  }

  void increaseColumnCount(int col) {
    if (col >= colCount) {
      final needed = col + 1 - colCount;
      for (var r = 0; r < rowCount; r++) {
        sheet.table[r].addAll(List.filled(needed, '', growable: true));
      }
      sheet.columnTypes.addAll(List.filled(needed, ColumnType.attributes));
    }
  }

  void decreaseRowCount(int row) {
    if (row == rowCount - 1) {
      while (row >= 0 && !sheet.table[row].any((cell) => cell.isNotEmpty)) {
        sheet.table.removeLast();
        row--;
      }
    }
  }

  double getColumnWidth(int col) {
    return getTargetLeft(col + 1) - getTargetLeft(col);
  }

  double calculateRequiredRowHeight(String text, int colId) {
    // 2. Determine the width available for the actual text
    final double availableWidth =
        getColumnWidth(colId) - PageConstants.horizontalPadding;
    return _layoutCalculator.calculateRowHeight(text, availableWidth);
  }

  double getDefaultRowHeight() {
    return PageConstants.defaultFontHeight + 2 * PageConstants.verticalPadding;
  }

  double getDefaultCellWidth() {
    return PageConstants.defaultCellWidth + 2 * PageConstants.horizontalPadding;
  }

  double getRowHeight(int row) {
    if (row < sheet.rowsBottomPos.length) {
      if (row == 0) {
        return sheet.rowsBottomPos[0];
      } else {
        return sheet.rowsBottomPos[row] - sheet.rowsBottomPos[row - 1];
      }
    }
    return getDefaultRowHeight();
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
    if (newValue.isNotEmpty || (row < rowCount && col < colCount)) {
      if (row >= rowCount) {
        final needed = row + 1 - rowCount;
        sheet.table.addAll(
          List.generate(
            needed,
            (_) => List.filled(colCount, '', growable: true),
          ),
        );
      }
      increaseColumnCount(col);
      prevValue = sheet.table[row][col];
      sheet.table[row][col] = newValue;
    }

    // Clean up empty rows/cols at the end
    if (newValue.isEmpty &&
        row < rowCount &&
        col < colCount &&
        (row == rowCount - 1 || col == colCount - 1) &&
        prevValue.isNotEmpty) {
      decreaseRowCount(row);
      if (col == colCount - 1) {
        int colId = col;
        bool canRemove = true;
        while (canRemove && colId >= 0) {
          for (var r = 0; r < rowCount; r++) {
            if (sheet.table[r][colId].isNotEmpty) {
              canRemove = false;
              break;
            }
          }
          if (canRemove) {
            for (var r = 0; r < rowCount; r++) {
              sheet.table[r].removeLast();
            }
            colId--;
          }
        }
      }
    }
    if (!historyNavigation) {
      _historyManager.recordCellChange(
        row,
        col,
        prevValue,
        newValue,
        onChange,
        keepPrevious,
      );
    }

    if (row >= sheet.rowsBottomPos.length && row >= rowCount) {
      updateRowColCount(visibleHeight: visibleWindowHeight, visibleWidth: visibleWindowWidth, notify: false);
      return;
    }
    double heightItNeeds = calculateRequiredRowHeight(newValue, col);
    if (heightItNeeds > getDefaultRowHeight() &&
        sheet.rowsBottomPos.length <= row) {
      int prevRowsBottomPosLength = sheet.rowsBottomPos.length;
      sheet.rowsBottomPos.addAll(
        List.filled(row + 1 - sheet.rowsBottomPos.length, 0),
      );
      for (int i = prevRowsBottomPosLength; i <= row; i++) {
        sheet.rowsBottomPos[i] = i == 0
            ? getDefaultRowHeight()
            : sheet.rowsBottomPos[i - 1] + getDefaultRowHeight();
      }
    }
    if (row < sheet.rowsBottomPos.length) {
      if (sheet.rowsManuallyAdjustedHeight.length <= row ||
          !sheet.rowsManuallyAdjustedHeight[row]) {
        double currentHeight = getRowHeight(row);
        if (heightItNeeds < currentHeight) {
          double heightItNeeded = calculateRequiredRowHeight(prevValue, col);
          if (heightItNeeded == currentHeight) {
            double newHeight = heightItNeeds;
            for (int j = 0; j < colCount; j++) {
              if (j == col) continue;
              newHeight = max(
                calculateRequiredRowHeight(sheet.table[row][j], j),
                newHeight,
              );
              if (newHeight == heightItNeeded) break;
            }
            if (newHeight < heightItNeeded) {
              double heightDiff = currentHeight - newHeight;
              for (int r = row; r < sheet.rowsBottomPos.length; r++) {
                sheet.rowsBottomPos[r] -= heightDiff;
              }
              if (newHeight == getDefaultRowHeight()) {
                int removeFrom = sheet.rowsBottomPos.length;
                for (int r = sheet.rowsBottomPos.length - 1; r >= 0; r--) {
                  if (r < sheet.rowsManuallyAdjustedHeight.length &&
                          sheet.rowsManuallyAdjustedHeight[r] ||
                      sheet.rowsBottomPos[r] >
                          (r == 0 ? 0 : sheet.rowsBottomPos[r - 1]) +
                              getDefaultRowHeight()) {
                    break;
                  }
                  removeFrom--;
                }
                sheet.rowsBottomPos = sheet.rowsBottomPos.sublist(
                  0,
                  removeFrom,
                );
              }
            }
          }
        } else if (heightItNeeds > currentHeight) {
          double heightDiff = heightItNeeds - currentHeight;
          for (int r = row; r < sheet.rowsBottomPos.length; r++) {
            sheet.rowsBottomPos[r] = sheet.rowsBottomPos[r] + heightDiff;
          }
        }
      }
    } else if (heightItNeeds == getDefaultRowHeight() &&
        row == sheet.rowsBottomPos.length - 1) {
      int i = row;
      while (sheet.rowsBottomPos[i] == getDefaultRowHeight() && row > 0) {
        sheet.rowsBottomPos.removeLast();
        i--;
      }
    }
    updateRowColCount(visibleHeight: visibleWindowHeight, visibleWidth: visibleWindowWidth, notify: false);
  }

  void saveAndCalculate({bool save = true, bool updateHistory = false}) {
    if (save) {
      if (updateHistory) {
        _historyManager.commit();
      }
      _dataManager.scheduleSheetSave(saveDelayMs);
    }
    _calculateExecutor.execute(
      () async {
        AnalysisResult result = await calculationService.runCalculation(
          sheet.table,
          sheet.columnTypes,
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
              message: "Could not find a valid sorting satisfying all constraints.",
            ),
          );
        }
        return result;
      },
      onComplete: (AnalysisResult result) {
        analysisResult = result;
        calculatedOnce = true;

        tableToAtt = result.tableToAtt;
        names = result.names;
        attToCol = result.attToCol;
        nameIndexes = result.nameIndexes;

        pathIndexes = result.pathIndexes;
        attToRefFromAttColToCol = result.attToRefFromAttColToCol;
        attToRefFromDepColToCol = result.attToRefFromDepColToCol;
        rowToAtt = result.rowToAtt;
        toMentioners = result.toMentioners;
        instrTable = result.instrTable;
        colToAtt = result.colToAtt;
        mentionsRoot.newChildren = null;
        mentionsRoot.rowId = _selectionManager.primarySelectedCell.x;
        mentionsRoot.colId = _selectionManager.primarySelectedCell.y;
        searchRoot.newChildren = null;
        _treeManager.populateTree([
          result.errorRoot,
          result.warningRoot,
          mentionsRoot,
          searchRoot,
          result.categoriesRoot,
          result.distPairsRoot,
        ]);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setColumnType(int col, ColumnType type, {bool updateHistory = true}) {
    if (updateHistory) {
      _historyManager.recordColumnTypeChange(col, getColumnType(col), type);
    }
    if (type == ColumnType.attributes) {
      if (col < colCount) {
        sheet.columnTypes[col] = type;
        if (col == sheet.columnTypes.length - 1) {
          while (col > 0) {
            col--;
            if (sheet.columnTypes[col] != ColumnType.attributes) {
              break;
            }
          }
          sheet.columnTypes = sheet.columnTypes.sublist(0, col + 1);
        }
      }
    } else {
      increaseColumnCount(col);
      sheet.columnTypes[col] = type;
    }
    notifyListeners();
    saveAndCalculate(updateHistory: true);
  }

  void applyDefaultColumnSequence() {
    setColumnType(0, ColumnType.names);
    setColumnType(1, ColumnType.dependencies);
    setColumnType(2, ColumnType.dependencies);
    setColumnType(3, ColumnType.dependencies);
    setColumnType(7, ColumnType.urls);
    setColumnType(8, ColumnType.dependencies);
  }

  void setPrimarySelection(
    int row,
    int col,
    bool keepSelection,
    bool updateMentions,
  ) {
    _selectionManager.setPrimarySelection(
      row,
      col,
      keepSelection,
      updateMentions,
    );
  }

  bool isPrimarySelectedCell(int row, int col) {
    return row == _selectionManager.primarySelectedCell.x &&
        col == _selectionManager.primarySelectedCell.y;
  }

  bool isCellSelected(int row, int col) {
    return selection.selectedCells.any(
      (cell) => cell.x == row && cell.y == col,
    );
  }

  void toggleNodeExpansion(NodeStruct node, bool isExpanded) {
    // Logic is now in the manager
    node.isExpanded = isExpanded;
    for (NodeStruct child in node.newChildren ?? []) {
      child.isExpanded = false;
    }
    _treeManager.populateTree([node]);
    notifyListeners();
  }

  Future<void> saveLastSelection(SelectionModel selection) async {
    await _dataManager.saveLastSelection(selection);
  }

  Future<void> saveSheet(String sheetName, SheetModel sheet) async {
    await _dataManager.saveSheetDirect(sheetName, sheet);
  }

  void populateTree(List<NodeStruct> nodes) {
    _treeManager.populateTree(nodes);
  }

  Point<int> get primarySelectedCell => _selectionManager.primarySelectedCell;

  Future<void> copySelectionToClipboard() async {
    await _clipboardManager.copySelectionToClipboard();
  }

  Future<void> pasteSelection() async {
    await _clipboardManager.pasteSelection();
  }

  void delete() {
    _clipboardManager.delete();
  }

  void selectAll() {
    _selectionManager.selectAll();
  }

  void notify() {
    notifyListeners();
  }

  int get tableViewRows => _selectionManager.selection.rowCount;
  int get tableViewCols => _selectionManager.selection.colCount;

  void updateRowColCount({double? visibleHeight, double? visibleWidth, bool notify = true}) {
    int targetRows = tableViewRows;
    int targetCols = tableViewCols;
    if (visibleHeight != null) {
      visibleWindowHeight = visibleHeight;
      targetRows = minRows(visibleWindowHeight);
    }
    if (visibleWidth != null) {
      visibleWindowWidth = visibleWidth;
      targetCols = minCols(visibleWindowWidth);
    }
    if (targetRows != tableViewRows || targetCols != tableViewCols) {
      _selectionManager.selection.rowCount = targetRows;
      _selectionManager.selection.colCount = targetCols;
      if (notify) {
        notifyListeners();
      }
    }
  }

  double getTargetTop(int row) {
    if (row <= 0) return 0.0;
    final int nbKnownBottomPos = sheet.rowsBottomPos.length;
    var rowsBottomPos = sheet.rowsBottomPos;
    final int tableHeight = nbKnownBottomPos == 0
        ? 0
        : rowsBottomPos.last.toInt();
    final double targetTop = row - 1 < nbKnownBottomPos
        ? rowsBottomPos[row - 1].toDouble()
        : tableHeight + (row - nbKnownBottomPos) * getDefaultRowHeight();
    return targetTop;
  }

  double getTargetLeft(int col) {
    if (col <= 0) return 0.0;
    final int nbKnownRightPos = sheet.colRightPos.length;
    var columnsRightPos = sheet.colRightPos;
    final int tableWidth = nbKnownRightPos == 0
        ? 0
        : columnsRightPos.last.toInt();
    final double targetRight = col - 1 < nbKnownRightPos
        ? columnsRightPos[col - 1].toDouble()
        : tableWidth + (col - nbKnownRightPos) * getDefaultCellWidth();
    return targetRight;
  }

  int minRows(double height) {
    double tableHeight = getTargetTop(rowCount - 1);
    if (height >= tableHeight) {
      return sheet.rowsBottomPos.length +
          (height - getTargetTop(sheet.rowsBottomPos.length - 1)) ~/ getDefaultRowHeight() + 1;
    }
    return rowCount;
  }

  int minCols(double width) {
    double tableWidth = getTargetLeft(colCount - 1);
    if (width >= tableWidth) {
      return sheet.colRightPos.length +
          (width - getTargetLeft(sheet.colRightPos.length - 1)) ~/ getDefaultCellWidth() + 1;
    }
    return colCount;
  }

  /// Triggers a visual scroll event to the Widget via the Stream
  void triggerScrollTo(int row, int col) {
    _scrollController.add(SpreadsheetScrollRequest.toCell(Point(row, col)));
  }
   
  void scrollToOffset({double? x, double? y, bool animate = false}) {
    _scrollController.add(
      SpreadsheetScrollRequest.toOffset(offsetX: x, offsetY: y, animate: animate),
    );
  }

  String? currentInitialInput; // Add this field

  void startEditing({String? initialInput}) {
    previousContent = getContent(primarySelectedCell.x, primarySelectedCell.y);
    currentInitialInput = initialInput; // Store it
    if (currentInitialInput != null) {
      onChanged(currentInitialInput!);
    }
    editingMode = true;
    notifyListeners();
  }

  void onChanged(String newValue) {
    updateCell(
      primarySelectedCell.x,
      primarySelectedCell.y,
      newValue,
      onChange: true,
    );
    notifyListeners();
    saveAndCalculate();
  }

  void stopEditing(bool updateHistory) {
    editingMode = false;
    currentInitialInput = null;
    notifyListeners();
    if (updateHistory && _historyManager.currentUpdateHistory != null) {
      saveAndCalculate(updateHistory: true);
    }
    discardCurrent();
  }

  void undo() {
    _historyManager.undo();
  }

  void redo() {
    _historyManager.redo();
  }

  bool editingMode = false;

  bool isCellEditing(int row, int col) =>
      editingMode &&
      primarySelectedCell.x == row &&
      primarySelectedCell.y == col;

  String previousContent = '';
}