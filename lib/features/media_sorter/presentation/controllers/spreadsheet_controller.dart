import 'dart:math';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
import 'package:trying_flutter/features/media_sorter/domain/entities/dyn_and_int.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/instr_struct.dart';

class SpreadsheetController extends ChangeNotifier {
  int saveDelayMs = 500;

  final GetSheetDataUseCase _getDataUseCase;
  final SaveSheetDataUseCase _saveSheetDataUseCase;
  final ParsePasteDataUseCase _parsePasteDataUseCase;
  final Map<String, ManageWaitingTasks> _saveExecutors = {};
  final ManageWaitingTasks _calculateExecutor = ManageWaitingTasks();
  AnalysisResult result = AnalysisResult();

  List<List<String>> table = [];
  List<String> columnTypes = [];
  String sheetName = "";
  int tableViewRows = 50;
  int tableViewCols = 50;
  List<String> availableSheets = [];
  Map<String, Map<String, dynamic>> loadedSheetsData = {};

  // Dimensions
  bool _isLoading = false;

  // Selection State
  Point<int> _selectionStart = Point(0, 0);
  Point<int> _selectionEnd = Point(0, 0);

  int all = SpreadsheetConstants.all;

  final NodeStruct errorRoot = NodeStruct(
    message: 'Error Log',
    newChildren: [],
    hideIfEmpty: true,
  );
  final NodeStruct warningRoot = NodeStruct(
    message: 'Warning Log',
    newChildren: [],
    hideIfEmpty: true,
  );
  final NodeStruct mentionsRoot = NodeStruct(
    message: 'Current selection',
    newChildren: [],
  );
  final NodeStruct searchRoot = NodeStruct(
    message: 'Search results',
    newChildren: [],
  );
  final NodeStruct categoriesRoot = NodeStruct(
    message: 'Categories',
    newChildren: [],
  );
  final NodeStruct distPairsRoot = NodeStruct(
    message: 'Distance Pairs',
    newChildren: [],
  );

  /// 2D table of attribute identifiers (row index or name)
  /// mentioned in each cell.
  List<List<HashSet<AttAndCol>>> tableToAtt = [];
  Map<String, Cell> names = {};
  Map<String, List<dynamic>> attToCol = {};
  List<int> nameIndexes = [];
  List<int> pathIndexes = [];

  /// Maps attribute identifiers (row index or name)
  /// to a map of pointers (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  Map<AttAndCol, Map<int, int>> attToRefFromAttColToCol = {};
  Map<AttAndCol, Map<int, List<int>>> attToRefFromDepColToCol = {};
  Map<int, Map<AttAndCol, int>> rowToAtt = {};

  /// Maps attribute identifiers (row index or name)
  /// to a map of mentioners (row index) to the column index
  Map<AttAndCol, Map<int, List<int>>> toMentioners = {};
  List<Map<InstrStruct, int>> instrTable = [];
  Map<dynamic, HashSet<AttAndCol>> colToAtt = {};

  SpreadsheetController({
    required GetSheetDataUseCase getDataUseCase,
    required SaveSheetDataUseCase saveSheetDataUseCase,
    required ParsePasteDataUseCase parsePasteDataUseCase,
  }) : _getDataUseCase = getDataUseCase,
       _saveSheetDataUseCase = saveSheetDataUseCase,
       _parsePasteDataUseCase = parsePasteDataUseCase {
    // Start loading immediately upon controller creation
    init();
  }

  // --- Initialization Logic ---
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      availableSheets = await _getDataUseCase.getAllSheetNames();
      sheetName = await _getDataUseCase.getLastOpenedSheetName();

      await loadSheetByName(sheetName);
    } catch (e) {
      debugPrint("Error loading sheet: $e");
      // Optionally handle error state here
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Getters
  bool get isLoading => _isLoading;
  int get rowCount => table.length;
  int get colCount => rowCount > 0 ? table[0].length : 0;

  Future<void> loadSheetByName(String name) async {
    _isLoading = true;
    notifyListeners();

    bool availableSheetsChanged = false;
    if (availableSheets.contains(name)) {
      if (loadedSheetsData.containsKey(name)) {
        table = loadedSheetsData[name]!["table"] as List<List<String>>;
        columnTypes = loadedSheetsData[name]!["columnTypes"] as List<String>;
      } else {
        _saveExecutors[name] = ManageWaitingTasks();
        try {
          var (iTable, iColumnTypes, iSelectionStart, iSelectionEnd) =
              await _getDataUseCase.loadSheet(name);
          table = iTable;
          columnTypes = iColumnTypes;
          _selectionStart = iSelectionStart;
          _selectionEnd = iSelectionEnd;
        } catch (e) {
          debugPrint("Error parsing sheet data for $name: $e");
        }
      }
    } else {
      table = [];
      columnTypes = [];
      availableSheets.add(name);
      availableSheetsChanged = true;
      _saveExecutors[name] = ManageWaitingTasks();
    }
    loadedSheetsData[name] = {"table": table, "columnTypes": columnTypes};
    _isLoading = false;
    notifyListeners();
    sheetName = name;
    _saveExecutors[sheetName]!.execute(() async {
      await _saveSheetDataUseCase.saveLastOpenedSheetName(name);
      if (availableSheetsChanged) {
        await _saveSheetDataUseCase.saveAllSheetNames(availableSheets);
      }
      await Future.delayed(Duration(milliseconds: saveDelayMs)); // Debounce
    });
    saveAndCalculate(save: false);
  }

  // --- Content Access ---
  String getContent(int row, int col) {
    if (row < rowCount && col < colCount) {
      return table[row][col];
    }
    return '';
  }

  void increaseColumnCount(int col) {
    if (col >= colCount) {
      final needed = col + 1 - colCount;
      for (var r = 0; r < rowCount; r++) {
        table[r].addAll(List.filled(needed, '', growable: true));
      }
      columnTypes.addAll(List.filled(needed, ColumnType.defaultType.name));
    }
  }

  void decreaseColumnCount(col) {
    if (col == columnTypes.length - 1) {
      bool canRemove = true;
      while (canRemove && col > 0) {
        for (var r = 0; r < rowCount; r++) {
          if (table[r][col].isNotEmpty) {
            canRemove = false;
            break;
          }
        }
        if (canRemove) {
          for (var r = 0; r < rowCount; r++) {
            table[r].removeLast();
          }
          col--;
        }
      }
      columnTypes = columnTypes.sublist(0, col + 1);
    }
  }

  void decreaseRowCount(int row) {
    if (row == rowCount - 1) {
      while (!table[row].any((cell) => cell.isNotEmpty) && row > 0) {
        table.removeLast();
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
        table.addAll(
          List.generate(
            needed,
            (_) => List.filled(colCount, '', growable: true),
          ),
        );
      }
      increaseColumnCount(col);
      table[row][col] = newValue;
    }
    if (newValue.isEmpty &&
        row < rowCount &&
        col < colCount &&
        (row == rowCount - 1 || col == colCount - 1) &&
        table[row][col].isNotEmpty) {
      decreaseRowCount(row);
      decreaseColumnCount(col);
    }
    notifyListeners();
    saveAndCalculate();
  }

  // --- Column Logic ---
  String getColumnType(int col) {
    if (col >= colCount) return ColumnType.defaultType.name;
    return columnTypes[col];
  }

  void saveAndCalculate({
    bool save = true,
    bool calculate = true,
  }) {
    if (save) {
      _saveExecutors[sheetName]!.execute(() async {
        await _saveSheetDataUseCase.saveSheet(
          sheetName,
          table,
          columnTypes,
          _selectionStart,
          _selectionEnd,
        );
        await Future.delayed(Duration(milliseconds: saveDelayMs));
      });
    }
    if (!calculate) {
      return;
    }
    _calculateExecutor.execute(() async {
      final calculateUsecase = CalculateUsecase(table, columnTypes);
      result = await compute(
        runCalculator,
        calculateUsecase.getMessage(table, columnTypes),
      );
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
      rowToAtt = result.rowToAtt;
      toMentioners = result.toMentioners;
      instrTable = result.instrTable;
      colToAtt = result.colToAtt;
      populateCellNode(mentionsRoot, _selectionStart.x, _selectionStart.y);
      populateTree(errorRoot);
      populateTree(warningRoot);
      populateTree(mentionsRoot);
      populateTree(searchRoot);
      populateTree(categoriesRoot);
      populateTree(distPairsRoot);
      notifyListeners();
    });
  }

  void setColumnType(int col, String type) {
    if (type == ColumnType.defaultType.name) {
      if (col < colCount) {
        columnTypes[col] = type;
        decreaseColumnCount(col);
      }
    } else {
      increaseColumnCount(col);
      columnTypes[col] = type;
    }
    saveAndCalculate();
  }

  /// Generates Excel-like column names (A, B, ... Z, AA, AB)
  String columnName(int colIndex) {
    String res = "";
    int index = colIndex;
    while (index >= 0) {
      res = String.fromCharCode((index % 26) + 65) + res;
      index = (index ~/ 26) - 1;
    }
    return res;
  }

  // --- Selection Logic ---
  void checkSelectChange(
    Point<int> newSelectionStart,
    Point<int> newSelectionEnd,
  ) {
    if (_selectionStart != newSelectionStart ||
        _selectionEnd != newSelectionEnd) {
      _selectionStart = newSelectionStart;
      _selectionEnd = newSelectionEnd;
      saveAndCalculate(calculate: false);
      populateCellNode(mentionsRoot, _selectionStart.x, _selectionStart.y);
      populateTree(mentionsRoot);
      notifyListeners();
    }
  }

  void selectCell(int row, int col) {
    var newSelectionStart = Point(row, col);
    var newSelectionEnd = Point(row, col);
    checkSelectChange(newSelectionStart, newSelectionEnd);
  }

  void selectRange(int startRow, int startCol, int endRow, int endCol) {
    var newSelectionStart = Point(startRow, startCol);
    var newSelectionEnd = Point(endRow, endCol);
    checkSelectChange(newSelectionStart, newSelectionEnd);
  }

  bool isCellSelected(int row, int col) {
    final startRow = min(_selectionStart.x, _selectionEnd.x);
    final endRow = max(_selectionStart.x, _selectionEnd.x);
    final startCol = min(_selectionStart.y, _selectionEnd.y);
    final endCol = max(_selectionStart.y, _selectionEnd.y);

    return row >= startRow && row <= endRow && col >= startCol && col <= endCol;
  }

  // --- Clipboard Logic ---
  Future<String?> copySelectionToClipboard() async {
    final startRow = min(_selectionStart.x, _selectionEnd.x);
    final endRow = max(_selectionStart.x, _selectionEnd.x);
    final startCol = min(_selectionStart.y, _selectionEnd.y);
    final endCol = max(_selectionStart.y, _selectionEnd.y);

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
    return text;
  }

  Future<void> pasteSelection() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text == null) return;

    // 1. Delegate Logic to UseCase
    // We normalize selection to ensure we paste from top-left
    int startRow = min(_selectionStart.x, _selectionEnd.x);
    int startCol = min(_selectionStart.y, _selectionEnd.y);

    final List<CellUpdate> updates = _parsePasteDataUseCase.execute(
      data!.text!,
      startRow,
      startCol,
    );

    // 2. Update UI & Persist
    for (var update in updates) {
      updateCell(update.row, update.col, update.value);
    }

    // Batch notification is better for performance than notifying inside the loop
    notifyListeners();
  }

  void selectAll() {
    selectRange(0, 0, rowCount - 1, colCount - 1);
  }

  void populateCellNode(NodeStruct root, int rowId, int colId) {
    if (rowId >= rowCount || colId >= colCount) return;
    root.message = '${columnName(colId)}$rowId: ${table[rowId][colId]}';
    root.newChildren = [];
    if (columnTypes[colId] == ColumnType.names.name ||
        columnTypes[colId] == ColumnType.filePath.name ||
        columnTypes[colId] == ColumnType.url.name) {
      root.newChildren!.add(
        NodeStruct(
          message: table[rowId][colId],
          att: AttAndCol(row: rowId),
        ),
      );
      return;
    }
    for (AttAndCol att in tableToAtt[rowId][colId]) {
      root.newChildren!.add(NodeStruct(att: att));
    }
  }

  void populateRowNode(NodeStruct root, int rowId) {
    if (root.instruction == SpreadsheetConstants.refFromAttColMsg) {
      root.message = root.instruction;
      for (int pointerRowId
          in attToRefFromAttColToCol[AttAndCol(row: rowId)]!.keys) {
        root.newChildren!.add(
          NodeStruct(att: AttAndCol(row: pointerRowId)),
        );
      }
    } else if (root.instruction == SpreadsheetConstants.refFromDepColMsg) {
      root.message = root.instruction;
      for (int pointerRowId
          in attToRefFromDepColToCol[AttAndCol(row: rowId)]!.keys) {
        root.newChildren!.add(
          NodeStruct(att: AttAndCol(row: pointerRowId)),
        );
      }
    } else {
      List<String> rowNames = [];
      for (final index in nameIndexes) {
        for (final name in tableToAtt[rowId][index]) {
          rowNames.add(name.name);
        }
      }
      root.message = 'Row $rowId: ${rowNames.join(', ')}';
      if (attToRefFromAttColToCol.containsKey(AttAndCol(row: rowId))) {
        root.newChildren!.add(
          NodeStruct(
            instruction: SpreadsheetConstants.refFromAttColMsg,
            att: AttAndCol(row: rowId),
          ),
        );
      }
      if (attToRefFromDepColToCol.containsKey(AttAndCol(row: rowId))) {
        root.newChildren!.add(
          NodeStruct(
            instruction: SpreadsheetConstants.refFromDepColMsg,
            att: AttAndCol(row: rowId),
          ),
        );
      }
      for (int colId = 0; colId < colCount; colId++) {
        if (table[rowId][colId].isNotEmpty) {
          root.newChildren!.add(
            NodeStruct(
              att: AttAndCol(row: rowId, col: colId),
            ),
          );
        }
      }
    }
  }

  void populateColNode(NodeStruct root, int colId) {
    root.message = 'Column ${columnName(colId)}';
    for (final att in colToAtt[colId]!) {
      root.newChildren!.add(NodeStruct(att: att));
    }
  }

  void populateTree(NodeStruct root) {
    // TODO keep same expansion if the user just moved, or even if there have been changes
    // List<int> newRowIndexes = [];
    // List<int> newColIndexes = [];
    // Map<String, String> newNameToOldName = {};
    var stack = [root];
    while (stack.isNotEmpty) {
      var node = stack.removeLast();
      if (node.newChildren == null) {
        node.newChildren = [];
        int rowId = node.att.row;
        int colId = node.att.col;
        if (rowId != all) {
          if (colId == all) {
            populateRowNode(node, rowId);
          } else {
            populateCellNode(node, rowId, colId);
          }
        } else if (colId != all) {
          populateColNode(node, colId);
        }
      }
      for (final child in node.newChildren!) {
        child.depth = node.depth + 1;
      }

      if (node.depth == 0) {
        for (int i = 0; i < node.children.length; i++) {
          var obj = node.children[i];
          if (obj.depth > 0) {
            break;
          }
          for (int j = 0; j < node.newChildren!.length; j++) {
            var newObj = node.newChildren![j];
            if (newObj.depth > 0 && obj == newObj) {
              newObj.depth = 0;
              break;
            }
          }
        }
      }
      node.children = node.newChildren!;
      if (node.depth < 2) {
        for (final child in node.children) {
          stack.add(child);
        }
      }
    }
  }

  void toggleNodeExpansion(NodeStruct node, bool isExpanded) {
    node.depth = isExpanded ? 0 : 1;
    populateTree(node);
    notifyListeners();
  }
}
