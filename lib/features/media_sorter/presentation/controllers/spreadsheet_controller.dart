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
import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/sorting_service.dart';
import 'package:trying_flutter/features/media_sorter/domain/mixins/get_names.dart';
import 'package:trying_flutter/features/media_sorter/domain/services/calculation_service.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/history_manager.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/calculate_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/sheet_data_manager.dart';
// Add the import for the new grid manager
import 'package:trying_flutter/features/media_sorter/presentation/logic/grid_manager.dart';

class SpreadsheetController extends ChangeNotifier with GetNames {
  int saveDelayMs = 500;

  late final TreeManager _treeManager;
  late final SelectionManager _selectionManager;
  late final ClipboardManager _clipboardManager;
  late final HistoryManager _historyManager;
  late final SheetDataManager _dataManager;
  late final GridManager _gridManager;

  // Proxy getters for DataManager properties to maintain API compatibility
  SheetModel get sheet => _dataManager.sheet;
  String get sheetName => _dataManager.sheetName;
  List<String> get availableSheets => _dataManager.availableSheets;
  Map<String, SheetModel> get loadedSheetsData => _dataManager.loadedSheetsData;
  Map<String, SelectionModel> get lastSelectedCells => _dataManager.lastSelectedCells;

  @override
  get columnTypes => sheet.columnTypes;

  // --- Grid Manager Proxy Getters ---
  Stream<SpreadsheetScrollRequest> get scrollStream => _gridManager.scrollStream;
  double get visibleWindowHeight => _gridManager.visibleWindowHeight;
  double get visibleWindowWidth => _gridManager.visibleWindowWidth;

  CalculationService calculationService = CalculationService();
  
  final ManageWaitingTasks<AnalysisResult> _calculateExecutor =
      ManageWaitingTasks<AnalysisResult>();
  AnalysisResult analysisResult = AnalysisResult();
  bool calculatedOnce = false;

  // Dimensions
  bool _isLoading = false;

  int all = SpreadsheetConstants.all;
  
  NodeStruct get mentionsRoot => _treeManager.mentionsRoot;
  NodeStruct get searchRoot => _treeManager.searchRoot;

  /// 2D table of attribute identifiers (row index or name)
  /// mentioned in each cell.
  @override
  List<List<HashSet<Attribute>>> tableToAtt = [];
  Map<String, Cell> names = {};
  Map<String, List<int>> attToCol = {};
  @override
  List<int> nameIndexes = [];
  List<int> get pathIndexes => _treeManager.pathIndexes;

  /// Maps attribute identifiers (row index or name)
  /// to a map of pointers (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  Map<Attribute, Map<int, Cols>> get attToRefFromAttColToCol => _treeManager.attToRefFromAttColToCol;
  Map<Attribute, Map<int, List<int>>> get attToRefFromDepColToCol => _treeManager.attToRefFromDepColToCol;
  Map<int, Map<Attribute, int>> get rowToAtt => _treeManager.rowToAtt;

  /// Maps attribute identifiers (row index or name)
  /// to a map of mentioners (row index) to the column index
  Map<Attribute, Map<int, List<int>>> get toMentioners => _treeManager.toMentioners;
  List<Map<InstrStruct, Cell>> get instrTable => _treeManager.instrTable;
  Map<int, HashSet<Attribute>> get colToAtt => _treeManager.colToAtt;

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
    _gridManager = GridManager(this);
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
    _gridManager.dispose();
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
    _gridManager.increaseColumnCount(col);
  }

  void decreaseRowCount(int row) {
    _gridManager.decreaseRowCount(row);
  }

  double getColumnWidth(int col) {
    return _gridManager.getColumnWidth(col);
  }

  double calculateRequiredRowHeight(String text, int colId) {
    return _gridManager.calculateRequiredRowHeight(text, colId);
  }

  double getDefaultRowHeight() {
    return _gridManager.getDefaultRowHeight();
  }

  double getDefaultCellWidth() {
    return _gridManager.getDefaultCellWidth();
  }

  double getRowHeight(int row) {
    return _gridManager.getRowHeight(row);
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

    // Delegate layout calculation to GridManager
    _gridManager.adjustRowHeightAfterUpdate(row, col, newValue, prevValue);
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

        // Update local controller state (needed for GetNames mixin etc)
        tableToAtt = result.tableToAtt;
        names = result.names;
        attToCol = result.attToCol;
        nameIndexes = result.nameIndexes;
        // ... update other local maps if needed for formula logic

        // DELEGATE TREE UPDATES TO MANAGER
        // This is the key change:
        _treeManager.onAnalysisComplete(result);
        
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
    _treeManager.toggleNodeExpansion(node, isExpanded);
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
    _gridManager.updateRowColCount(
      visibleHeight: visibleHeight,
      visibleWidth: visibleWidth,
      notify: notify,
    );
  }

  double getTargetTop(int row) {
    return _gridManager.getTargetTop(row);
  }

  double getTargetLeft(int col) {
    return _gridManager.getTargetLeft(col);
  }

  int minRows(double height) {
    return _gridManager.minRows(height);
  }

  int minCols(double width) {
    return _gridManager.minCols(width);
  }

  /// Triggers a visual scroll event to the Widget via the Stream
  void triggerScrollTo(int row, int col) {
    _gridManager.triggerScrollTo(row, col);
  }
    
  void scrollToOffset({double? x, double? y, bool animate = false}) {
    _gridManager.scrollToOffset(x: x, y: y, animate: animate);
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