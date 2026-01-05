import 'dart:async'; // Add this import
import 'dart:math';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/calculate_usecase.dart';
import '../../domain/usecases/get_sheet_data_usecase.dart';
import '../../domain/usecases/save_sheet_data_usecase.dart'; // Assume created
import '../../domain/entities/column_type.dart';
import '../../domain/usecases/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import '../../domain/usecases/manage_waiting_tasks.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/isolate_messages.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/instr_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/nodes_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/tree_manager.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/selection_manager.dart';
import 'package:trying_flutter/features/media_sorter/presentation/logic/clipboard_manager.dart';
import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/presentation/constants/page_constants.dart';
import 'package:trying_flutter/features/media_sorter/data/models/selection_model.dart';
import 'dart:io';

class CellUpdateHistory {
  Point<int> cell;
  String previousValue;
  String newValue;
  CellUpdateHistory({required this.cell, required this.previousValue, required this.newValue});
}

class UpdateHistory {
  static const String updateCellContent = "updateCellContent";
  static const String updateColumnType = "updateColumnType";
  final String key;
  final DateTime timestamp;
  final List<CellUpdateHistory>? updatedCells = [];
  int? colId;
  ColumnType? previousColumnType;
  ColumnType? newColumnType;
  UpdateHistory({required this.key, required this.timestamp, this.colId, this.previousColumnType, this.newColumnType});
}

class SpreadsheetController extends ChangeNotifier {
  int saveDelayMs = 500;

  late final TreeManager _treeManager;
  late final SelectionManager _selectionManager;
  late final ClipboardManager _clipboardManager;
  Size _visibleWindowSize = Size.zero;

  // --- Scroll Stream Controller ---
  final StreamController<Point<int>> _scrollToCellController =
      StreamController<Point<int>>.broadcast();
  Stream<Point<int>> get scrollToCellStream => _scrollToCellController.stream;

  final GetSheetDataUseCase _getDataUseCase;
  final SaveSheetDataUseCase _saveSheetDataUseCase;
  final ManageWaitingTasks<void> _saveLastSelectionExecutor =
      ManageWaitingTasks<void>();
  final Map<String, ManageWaitingTasks<void>> _saveExecutors = {};
  final ManageWaitingTasks<AnalysisResult> _calculateExecutor =
      ManageWaitingTasks<AnalysisResult>();
  NodesUsecase nodesUsecase = NodesUsecase(AnalysisResult());

  SheetModel sheet = SheetModel.empty();
  String sheetName = "";
  int tableViewRows = 50;
  int tableViewCols = 50;
  List<String> availableSheets = [];
  Map<String, SheetModel> loadedSheetsData = {};
  Map<String, SelectionModel> lastSelectedCells = {};
  UpdateHistory? currentUpdateHistory;

  // Dimensions
  bool _isLoading = false;

  int all = SpreadsheetConstants.all;

  final NodeStruct mentionsRoot = NodeStruct(
    instruction: SpreadsheetConstants.selectionMsg
  );
  final NodeStruct searchRoot = NodeStruct(
    instruction: SpreadsheetConstants.searchMsg
  );

  /// 2D table of attribute identifiers (row index or name)
  /// mentioned in each cell.
  List<List<HashSet<Attribute>>> tableToAtt = [];
  Map<String, Cell> names = {};
  Map<String, List<int>> attToCol = {};
  List<int> nameIndexes = [];
  List<int> pathIndexes = [];

  /// Maps attribute identifiers (row index or name)
  /// to a map of pointers (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  Map<Attribute, Map<int, List<int>>> attToRefFromAttColToCol = {};
  Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol = {};
  Map<int, Map<Attribute, int>> rowToAtt = {};

  /// Maps attribute identifiers (row index or name)
  /// to a map of mentioners (row index) to the column index
  Map<Attribute, Map<int, List<int>>> toMentioners = {};
  List<Map<InstrStruct, int>> instrTable = [];
  Map<int, HashSet<Attribute>> colToAtt = {};

  SelectionModel get selection => _selectionManager.selection;

  SpreadsheetController({
    required GetSheetDataUseCase getDataUseCase,
    required SaveSheetDataUseCase saveSheetDataUseCase,
    required ParsePasteDataUseCase parsePasteDataUseCase,
  }) : _getDataUseCase = getDataUseCase,
       _saveSheetDataUseCase = saveSheetDataUseCase {
    _treeManager = TreeManager(this);
    _selectionManager = SelectionManager(this);
    _clipboardManager = ClipboardManager(this);
    init();
  }

  bool isValidSheetName(String name) {
    return name.isNotEmpty &&
        !name.contains(RegExp(r'[\\/:*?"<>|]')) &&
        name != SpreadsheetConstants.noSPNameFound;
  }

  // --- Initialization Logic ---
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    // await _saveSheetDataUseCase.clearAllData();
    await _saveSheetDataUseCase.initialize();
    try {
      sheetName = await _getDataUseCase.getLastOpenedSheetName();
    } catch (e) {
      await _saveSheetDataUseCase.saveLastOpenedSheetName(sheetName);
    }
    try {
      await _getDataUseCase.getLastSelection();
    } catch (e) {
      await saveLastSelection(SelectionModel.empty());
    }

    availableSheets = await _getDataUseCase.getAllSheetNames();
    if (!isValidSheetName(sheetName)) {
      if (availableSheets.isNotEmpty) {
        sheetName = availableSheets[0];
      } else {
        sheetName = SpreadsheetConstants.defaultSheetName;
      }
      _saveSheetDataUseCase.saveLastOpenedSheetName(sheetName);
    }
    bool availableSheetsChanged = false;
    if (!availableSheets.contains(sheetName)) {
      availableSheets.add(sheetName);
      availableSheetsChanged = true;
      debugPrint(
        "Last opened sheet $sheetName not found in available sheets, adding it.",
      );
    }
    lastSelectedCells = await _getDataUseCase.getAllLastSelected();
    bool changed = false;
    for (var name in availableSheets) {
      if (!lastSelectedCells.containsKey(name)) {
        lastSelectedCells[name] = SelectionModel.empty();
        changed = true;
        debugPrint(
          "No last selected cell for sheet $name, defaulting to (0,0)",
        );
      }
    }
    if (changed) {
      _saveSheetDataUseCase.saveAllLastSelected(lastSelectedCells);
    }
    for (var name in lastSelectedCells.keys) {
      if (!availableSheets.contains(name)) {
        availableSheets.add(name);
        availableSheetsChanged = true;
      }
    }
    if (availableSheetsChanged) {
      _saveSheetDataUseCase.saveAllSheetNames(availableSheets);
    }

    await loadSheetByName(sheetName, init: true);
  }

  @override
  void dispose() {
    _scrollToCellController.close();
    super.dispose();
  }

  // Getters
  bool get isLoading => _isLoading;
  int get rowCount => sheet.table.length;
  int get colCount => rowCount > 0 ? sheet.table[0].length : 0;

  Future<void> loadSheetByName(String name, {bool init = false}) async {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    if (!init) {
      lastSelectedCells[sheetName] = _selectionManager.selection;
      _saveSheetDataUseCase.saveAllLastSelected(lastSelectedCells);
      _saveSheetDataUseCase.saveLastOpenedSheetName(name);
    }

    if (availableSheets.contains(name)) {
      if (loadedSheetsData.containsKey(name)) {
        sheet = loadedSheetsData[name]!;
        _selectionManager.selection = lastSelectedCells[name]!;
      } else {
        _saveExecutors[name] = ManageWaitingTasks<void>();
        try {
          sheet = await _getDataUseCase.loadSheet(name);
          if (init) {
            _selectionManager.selection = await _getDataUseCase
                .getLastSelection();
          } else {
            _selectionManager.selection = lastSelectedCells[name]!;
          }
        } catch (e) {
          debugPrint("Error parsing sheet data for $name: $e");
          sheet = SheetModel.empty();
          _selectionManager.selection = SelectionModel.empty();
        }
      }
    } else {
      sheet = SheetModel.empty();
      _selectionManager.selection = SelectionModel.empty();
      availableSheets.add(name);
      _saveSheetDataUseCase.saveAllSheetNames(availableSheets);
      _saveExecutors[name] = ManageWaitingTasks<void>();
    }
    if (!init) {
      await saveLastSelection(selection);
    }
    loadedSheetsData[name] = sheet;
    sheetName = name;
    saveAndCalculate(save: false);
    notifyListeners();
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
      while (!sheet.table[row].any((cell) => cell.isNotEmpty) && row > 0) {
        sheet.table.removeLast();
        sheet.rowsBottomPos.removeLast();
        row--;
      }
    }
  }

  // This must be a static method or a top-level function.
  // It cannot be a normal instance method.
  static AnalysisResult _isolateHandler(IsolateMessage message) {
    // 1. Handle Debug Delay (Synchronously)
    // Inside an isolate, use sleep() instead of Future.delayed to block execution
    // without returning a Future.
    sleep(Duration(milliseconds: SpreadsheetConstants.debugDelayMs));

    // 2. Run the calculation
    // You must move the logic of 'runCalculator' here, or make runCalculator
    // static and pass 'message' to it.
    return runCalculator(message); 
  }

  static AnalysisResult runCalculator(IsolateMessage message) {
    final Object dataPackage = switch (message) {
      RawDataMessage m => m.table,
      TransferableDataMessage m => m.dataPackage,
    };
    final worker = CalculateUsecase(dataPackage, message.columnTypes);
    return worker.run();
  }

  // --- Logic to Measure Text Wrapping ---
  double _calculateRequiredRowHeight(String text) {
    if (text.isEmpty) return getDefaultRowHeight();

    // Use TextPainter to measure how the text will wrap
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 14), // Must match the widget style
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    textPainter.layout(
      minWidth: 0, 
      maxWidth: PageConstants.defaultCellWidth - 2 * PageConstants.horizontalPadding,
    );

    return textPainter.height + 2 * PageConstants.verticalPadding;
  }

  double getDefaultRowHeight() {
    return PageConstants.defaultFontHeight + 2 * PageConstants.verticalPadding;
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

  void updateCell(int row, int col, String newValue, {bool updateHistory = true}) {
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
        bool canRemove = true;
        while (canRemove && col > 0) {
          for (var r = 0; r < rowCount; r++) {
            if (sheet.table[r][col].isNotEmpty) {
              canRemove = false;
              break;
            }
          }
          if (canRemove) {
            for (var r = 0; r < rowCount; r++) {
              sheet.table[r].removeLast();
            }
            col--;
          }
        }
      }
    }
    if (updateHistory) {
      currentUpdateHistory ??= UpdateHistory(
          key: UpdateHistory.updateCellContent,
          timestamp: DateTime.now(),
        );
      currentUpdateHistory!.updatedCells!.add(CellUpdateHistory(
        cell: Point(row, col),
        previousValue: prevValue,
        newValue: newValue,
      ));
    }
    
    if (row >= rowCount || col >= colCount) {
      return;
    }
    double heightItNeeds = _calculateRequiredRowHeight(newValue);
    if (heightItNeeds > getDefaultRowHeight() && sheet.rowsBottomPos.length <= row) {
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
          double heightItNeeded = _calculateRequiredRowHeight(prevValue);
          if (heightItNeeded == currentHeight) {
            double newHeight = heightItNeeds;
            for (int j = 0; j < colCount; j++) {
              if (j == col) continue;
              newHeight = max(
                _calculateRequiredRowHeight(sheet.table[row][j]),
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
      } // TODO: else
    }
  }

  // --- Column Logic ---
  ColumnType getColumnType(int col) {
    if (col >= colCount) return ColumnType.attributes;
    return sheet.columnTypes[col];
  }

  void saveAndCalculate({bool save = true}) {
    if (save) {
      if (sheet.historyIndex < sheet.updateHistories.length - 1) {
        sheet.updateHistories =
            sheet.updateHistories.sublist(0, sheet.historyIndex + 1);
      }
      sheet.updateHistories.add(currentUpdateHistory!);
      sheet.historyIndex++;
      currentUpdateHistory = null;
      _saveExecutors[sheetName]!.execute(() async {
        await _saveSheetDataUseCase.saveSheet(sheetName, sheet);
        await Future.delayed(Duration(milliseconds: saveDelayMs));
      });
    }
    _calculateExecutor.execute(
      () async {
        final calculateUsecase = CalculateUsecase(
          sheet.table,
          sheet.columnTypes,
        );
        return await compute(
          _isolateHandler,
          calculateUsecase.getMessage(sheet.table, sheet.columnTypes),
        );
      },
      onComplete: (AnalysisResult result) {
        nodesUsecase = NodesUsecase(result);

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
          nodesUsecase.analysisResult.errorRoot,
          nodesUsecase.analysisResult.warningRoot,
          mentionsRoot,
          searchRoot,
          nodesUsecase.analysisResult.categoriesRoot,
          nodesUsecase.analysisResult.distPairsRoot,
        ]);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setColumnType(int col, ColumnType type, {bool updateHistory = true}) {
    if (updateHistory) {
      currentUpdateHistory ??= UpdateHistory(
          key: UpdateHistory.updateColumnType,
          timestamp: DateTime.now(),
          colId: col,
          previousColumnType: getColumnType(col),
        newColumnType: type,
      );
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
    saveAndCalculate();
  }

  void selectCell(int row, int col, bool keepSelection, bool updateMentions) {
    _selectionManager.setPrimarySelection(row, col, keepSelection, updateMentions);
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

  String getColumnLabel(int col) {
    return nodesUsecase.getColumnLabel(col);
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
    _saveLastSelectionExecutor.execute(() async {
      await _saveSheetDataUseCase.saveLastSelection(selection);
      await Future.delayed(Duration(milliseconds: saveDelayMs));
    });
  }

  Future<void> saveSheet(String sheetName, SheetModel sheet) async {
    await _saveSheetDataUseCase.saveSheet(sheetName, sheet);
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

  void clearSelection(bool save) {
    _clipboardManager.clearSelection(save);
  }

  void delete() {
    _clipboardManager.delete();
  }

  void undo() {
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
          updateHistory: false,
        );
      }
    } else if (lastUpdate.key == UpdateHistory.updateColumnType) {
      if (lastUpdate.colId != null && lastUpdate.previousColumnType != null) {
        setColumnType(lastUpdate.colId!, lastUpdate.previousColumnType!, updateHistory: false);
      }
    }
    sheet.historyIndex--;
    saveAndCalculate();
  }

  void redo() {
    if (sheet.historyIndex + 1 >= sheet.updateHistories.length) {
      return;
    }
    final nextUpdate = sheet.updateHistories[sheet.historyIndex + 1];
    if (nextUpdate.key == UpdateHistory.updateCellContent) {
      for (var cellUpdate in nextUpdate.updatedCells!) {
        updateCell(
          cellUpdate.cell.x,
          cellUpdate.cell.y,
          cellUpdate.newValue,
          updateHistory: false,
        );
      }
    } else if (nextUpdate.key == UpdateHistory.updateColumnType) {
      if (nextUpdate.colId != null && nextUpdate.newColumnType != null) {
        setColumnType(nextUpdate.colId!, nextUpdate.newColumnType!, updateHistory: false);
      }
    }
    sheet.historyIndex++;
    saveAndCalculate();
  }

  void selectAll() {
    _selectionManager.selectAll();
  }

  void notify() {
    notifyListeners();
  }

  void updateRowCount(int newCount) {
    if (tableViewRows == newCount) return;
    tableViewRows = newCount;
    notifyListeners();
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
    const double cellWidth = PageConstants.defaultCellWidth;
    final int nbKnownRightPos = sheet.colRightPos.length;
    var columnsRightPos = sheet.colRightPos;
    final int tableWidth = nbKnownRightPos == 0
        ? 0
        : columnsRightPos.last.toInt();
    final double targetRight = col - 1 < nbKnownRightPos
        ? columnsRightPos[col - 1].toDouble()
        : tableWidth + (col - nbKnownRightPos) * cellWidth;
    return targetRight;
  }

  int get minRows {
    double tableHeight = getTargetTop(rowCount - 1);
    if (sheet.rowsBottomPos.isNotEmpty &&
        _visibleWindowSize.height > tableHeight) {
      return sheet.rowsBottomPos.length +
          (_visibleWindowSize.height - tableHeight) ~/
              PageConstants.defaultFontHeight;
    }
    return rowCount;
  }

  Size get visibleWindowSize => _visibleWindowSize;

  void updateVisibleWindowSize(Size newSize) {
    // PREVENT INFINITE LOOP: Only notify if the size actually changed
    if (_visibleWindowSize != newSize) {
      _visibleWindowSize = newSize;
      notifyListeners();
    }
  }

  /// Triggers a visual scroll event to the Widget via the Stream
  void triggerScrollTo(int row, int col) {
    _scrollToCellController.add(Point(row, col));
  }

  String? currentInitialInput; // Add this field

  void startEditing({String? initialInput}) {
    previousContent =
        getContent(primarySelectedCell.x, primarySelectedCell.y);
    currentInitialInput = initialInput; // Store it
    editingMode = true;
    notifyListeners();
  }

  void saveEdit(String newValue) {
    updateCell(primarySelectedCell.x, primarySelectedCell.y, newValue);
    saveAndCalculate();
  }

  void stopEditing() {
    editingMode = false;
    currentInitialInput = null;
    notifyListeners();
  }

  bool editingMode = false;

  bool isCellEditing(int row, int col) =>
      editingMode &&
      primarySelectedCell.x == row &&
      primarySelectedCell.y == col;
  
  String previousContent = '';

}
