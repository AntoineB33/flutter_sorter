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

  // Dimensions
  bool _isLoading = false;

  int all = SpreadsheetConstants.all;

  final NodeStruct errorRoot = NodeStruct(
    instruction: SpreadsheetConstants.errorMsg,
    newChildren: [],
    hideIfEmpty: true,
  );
  final NodeStruct warningRoot = NodeStruct(
    instruction: SpreadsheetConstants.warningMsg,
    newChildren: [],
    hideIfEmpty: true,
  );
  final NodeStruct mentionsRoot = NodeStruct(
    instruction: SpreadsheetConstants.selectionMsg,
    newChildren: [],
  );
  final NodeStruct searchRoot = NodeStruct(
    instruction: SpreadsheetConstants.searchMsg,
    newChildren: [],
  );
  final NodeStruct categoriesRoot = NodeStruct(
    instruction: SpreadsheetConstants.categoryMsg,
    newChildren: [],
  );
  final NodeStruct distPairsRoot = NodeStruct(
    instruction: SpreadsheetConstants.distPairsMsg,
    newChildren: [],
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
      sheet.columnTypes.addAll(List.filled(needed, ColumnType.attributes.name));
    }
  }

  void decreaseColumnCount(col) {
    if (col == sheet.columnTypes.length - 1) {
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
      sheet.columnTypes = sheet.columnTypes.sublist(0, col + 1);
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

  static AnalysisResult runCalculator(IsolateMessage message) {
    final Object dataPackage = switch (message) {
      RawDataMessage m => m.table,
      TransferableDataMessage m => m.dataPackage,
    };
    final worker = CalculateUsecase(dataPackage, message.columnTypes);
    return worker.run();
  }

  void updateCell(int row, int col, String newValue) {
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
      sheet.table[row][col] = newValue;
    }
    if (newValue.isEmpty &&
        row < rowCount &&
        col < colCount &&
        (row == rowCount - 1 || col == colCount - 1) &&
        sheet.table[row][col].isNotEmpty) {
      decreaseRowCount(row);
      decreaseColumnCount(col);
    }

    int newLines = '\n'.allMatches(newValue).length + 1;
    double heightItNeeds =
        newLines * PageConstants.defaultFontHeight +
        2 * PageConstants.defaultHeightPadding;
    if (newLines > 1 && sheet.rowsBottomPos.length <= row) {
      int prevRowsBottomPosLength = sheet.rowsBottomPos.length;
      sheet.rowsBottomPos.addAll(
        List.filled(row + 1 - sheet.rowsBottomPos.length, 0),
      );
      for (int i = prevRowsBottomPosLength; i <= row; i++) {
        sheet.rowsBottomPos[i] = i == 0
            ? PageConstants.defaultFontHeight +
                  2 * PageConstants.defaultHeightPadding
            : sheet.rowsBottomPos[i - 1] +
                  PageConstants.defaultFontHeight +
                  2 * PageConstants.defaultHeightPadding;
      }
    }
    if (row < sheet.rowsBottomPos.length) {
      if (sheet.rowsManuallyAdjustedHeight.length <= row ||
          !sheet.rowsManuallyAdjustedHeight[row]) {
        if (heightItNeeds < sheet.rowsBottomPos[row]) {
          int prevLinesNb = '\n'.allMatches(sheet.table[row][col]).length + 1;
          double heightItNeeded =
              prevLinesNb * PageConstants.defaultFontHeight +
              2 * PageConstants.defaultHeightPadding;
          if (heightItNeeded == sheet.rowsBottomPos[row]) {
            int maxLinesNb = newLines;
            for (int j = 0; j <= colCount; j++) {
              if (j == col) continue;
              maxLinesNb = max(
                '\n'.allMatches(sheet.table[row][j]).length + 1,
                maxLinesNb,
              );
              if (maxLinesNb == prevLinesNb) break;
            }
            if (maxLinesNb < prevLinesNb) {
              double newHeight =
                  maxLinesNb * PageConstants.defaultFontHeight +
                  2 * PageConstants.defaultHeightPadding;
              double heightDiff = sheet.rowsBottomPos[row] - newHeight;
              for (int r = row; r < sheet.rowsBottomPos.length; r++) {
                sheet.rowsBottomPos[r] = sheet.rowsBottomPos[r] - heightDiff;
              }
              if (maxLinesNb == 1) {
                int removeFrom = sheet.rowsBottomPos.length;
                for (int r = sheet.rowsBottomPos.length - 1; r >= 0; r--) {
                  if (r < sheet.rowsManuallyAdjustedHeight.length &&
                          sheet.rowsManuallyAdjustedHeight[r] ||
                      sheet.rowsBottomPos[r] >
                          (r == 0 ? 0 : sheet.rowsBottomPos[r - 1]) +
                              PageConstants.defaultFontHeight +
                              2 * PageConstants.defaultHeightPadding) {
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
        } else if (heightItNeeds > sheet.rowsBottomPos[row]) {
          double heightDiff = heightItNeeds - sheet.rowsBottomPos[row];
          for (int r = row; r < sheet.rowsBottomPos.length; r++) {
            sheet.rowsBottomPos[r] = sheet.rowsBottomPos[r] + heightDiff;
          }
        }
      } // TODO: else
    }
  }

  // --- Column Logic ---
  String getColumnType(int col) {
    if (col >= colCount) return ColumnType.attributes.name;
    return sheet.columnTypes[col];
  }

  void saveAndCalculate({bool save = true}) {
    if (save) {
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
          runCalculator,
          calculateUsecase.getMessage(sheet.table, sheet.columnTypes),
        );
      },
      onComplete: (AnalysisResult result) {
        nodesUsecase = NodesUsecase(result);
        errorRoot.newChildren = result.errorRoot.newChildren;
        warningRoot.newChildren = result.warningRoot.newChildren;
        mentionsRoot.newChildren = result.mentionsRoot.newChildren;
        searchRoot.newChildren = result.searchRoot.newChildren;
        categoriesRoot.newChildren = result.categoriesRoot.newChildren;
        distPairsRoot.newChildren = result.distPairsRoot.newChildren;

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
        mentionsRoot.rowId = _selectionManager.primarySelectedCell.x;
        mentionsRoot.colId = _selectionManager.primarySelectedCell.y;
        _treeManager.populateTree([
          errorRoot,
          warningRoot,
          mentionsRoot,
          searchRoot,
          categoriesRoot,
          distPairsRoot,
        ]);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setColumnType(int col, String type) {
    if (type == ColumnType.attributes.name) {
      if (col < colCount) {
        sheet.columnTypes[col] = type;
        decreaseColumnCount(col);
      }
    } else {
      increaseColumnCount(col);
      sheet.columnTypes[col] = type;
    }
    saveAndCalculate();
  }

  void selectCell(int row, int col) {
    _selectionManager.selectCell(row, col);
  }

  bool isCellSelected(int row, int col) {
    return row == _selectionManager.primarySelectedCell.x &&
        col == _selectionManager.primarySelectedCell.y;
  }

  String getColumnLabel(int col) {
    return nodesUsecase.getColumnLabel(col);
  }

  void toggleNodeExpansion(NodeStruct node, bool isExpanded) {
    // Logic is now in the manager
    node.isExpanded = isExpanded;
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

  Future<void> clearSelection() async {
    await _clipboardManager.clearSelection();
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
    const double cellHeight = PageConstants.defaultFontHeight;
    final int nbKnownBottomPos = sheet.rowsBottomPos.length;
    var rowsBottomPos = sheet.rowsBottomPos;
    final int tableHeight = nbKnownBottomPos == 0
        ? 0
        : rowsBottomPos.last.toInt();
    final double targetTop = row - 1 < nbKnownBottomPos
        ? rowsBottomPos[row - 1].toDouble()
        : tableHeight + (row - nbKnownBottomPos) * cellHeight;
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

  bool _editingMode = false;
  bool get isEditing => _editingMode;

  bool isCellEditing(int row, int col) =>
      _editingMode && primarySelectedCell.x == row &&
      primarySelectedCell.y == col;

  void startEditing() {
    _editingMode = true;
    notifyListeners();
  }

  void saveEdit(String newValue) {
    if (_editingMode) {
      updateCell(primarySelectedCell.x, primarySelectedCell.y, newValue);
      saveAndCalculate();
      _editingMode = false;
    }
  }

  void cancelEditing() {
    _editingMode = false;
    notifyListeners();
  }
}
