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
  final Map<String, ManageWaitingTasks<void>> _saveExecutors = {};
  final ManageWaitingTasks<AnalysisResult> _calculateExecutor = ManageWaitingTasks<AnalysisResult>();
  AnalysisResult result = AnalysisResult();
  bool _isDisposed = false;

  List<List<String>> table = [];
  List<String> columnTypes = [];
  String sheetName = "";
  int tableViewRows = 50;
  int tableViewCols = 50;
  List<String> availableSheets = [];
  Map<String, Map<String, dynamic>> loadedSheetsData = {};
  Map<String, Point<int>> lastSelectedCells = {};

  // Dimensions
  bool _isLoading = false;

  // Selection State
  Point<int> _selectionStart = Point(0, 0);
  Point<int> _selectionEnd = Point(0, 0);

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
  List<List<HashSet<CellWithName>>> tableToAtt = [];
  Map<String, Cell> names = {};
  Map<String, List<dynamic>> attToCol = {};
  List<int> nameIndexes = [];
  List<int> pathIndexes = [];

  /// Maps attribute identifiers (row index or name)
  /// to a map of pointers (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  Map<CellWithName, Map<int, int>> attToRefFromAttColToCol = {};
  Map<CellWithName, Map<int, List<int>>> attToRefFromDepColToCol = {};
  Map<int, Map<CellWithName, int>> rowToAtt = {};

  /// Maps attribute identifiers (row index or name)
  /// to a map of mentioners (row index) to the column index
  Map<CellWithName, Map<int, List<int>>> toMentioners = {};
  List<Map<InstrStruct, int>> instrTable = [];
  Map<dynamic, HashSet<CellWithName>> colToAtt = {};

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

    // await _saveSheetDataUseCase.clearAllData();
    availableSheets = await _getDataUseCase.getAllSheetNames();
    sheetName = await _getDataUseCase.getLastOpenedSheetName();
    if (!availableSheets.contains(sheetName)) {
      availableSheets.add(sheetName);
      debugPrint("Last opened sheet $sheetName not found in available sheets, adding it.");
    }
    lastSelectedCells = await _getDataUseCase.getAllLastSelected(availableSheets);

    await loadSheetByName(sheetName, init: true);
  }

  // Getters
  bool get isLoading => _isLoading;
  int get rowCount => table.length;
  int get colCount => rowCount > 0 ? table[0].length : 0;

  Future<void> loadSheetByName(String name, {bool init = false}) async {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    if (!init) {
      lastSelectedCells[sheetName] = _selectionStart;
      _saveSheetDataUseCase.saveAllLastSelected(lastSelectedCells);
    }

    bool availableSheetsChanged = false;
    if (availableSheets.contains(name)) {
      if (loadedSheetsData.containsKey(name)) {
        table = loadedSheetsData[name]!["table"] as List<List<String>>;
        columnTypes = loadedSheetsData[name]!["columnTypes"] as List<String>;
        _selectionStart = lastSelectedCells[name]!;
        _selectionEnd = lastSelectedCells[name]!;
      } else {
        _saveExecutors[name] = ManageWaitingTasks<void>();
        try {
          var (iTable, iColumnTypes) =
              await _getDataUseCase.loadSheet(name);
          table = iTable;
          columnTypes = iColumnTypes;
          if (init) {
            _selectionStart = await _getDataUseCase.getLastSelectedCell();
          } else {
            _selectionStart = lastSelectedCells[name]!;
            _selectionEnd = lastSelectedCells[name]!;
          }
        } catch (e) {
          debugPrint("Error parsing sheet data for $name: $e");
          table = [];
          columnTypes = [];
          _selectionStart = Point(0, 0);
          _selectionEnd = Point(0, 0);
        }
      }
    } else {
      table = [];
      columnTypes = [];
      availableSheets.add(name);
      availableSheetsChanged = true;
      _saveExecutors[name] = ManageWaitingTasks<void>();
    }
    loadedSheetsData[name] = {"table": table, "columnTypes": columnTypes};
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
      columnTypes.addAll(List.filled(needed, ColumnType.attributes.name));
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
  }

  // --- Column Logic ---
  String getColumnType(int col) {
    if (col >= colCount) return ColumnType.attributes.name;
    return columnTypes[col];
  }

  void saveAndCalculate({bool save = true, bool calculate = true}) {
    if (save) {
      _saveExecutors[sheetName]!.execute(() async {
        await _saveSheetDataUseCase.saveSheet(
          sheetName,
          table,
          columnTypes
        );
        await Future.delayed(Duration(milliseconds: saveDelayMs));
      });
    }
    if (!calculate) {
      return;
    }
    _calculateExecutor.execute(() async {
      final calculateUsecase = CalculateUsecase(table, columnTypes);
      return await compute(
        runCalculator,
        calculateUsecase.getMessage(table, columnTypes),
      );
    },
    onComplete: (AnalysisResult result) {
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
      mentionsRoot.row = _selectionStart.x;
      mentionsRoot.col = _selectionStart.y;
      populateTree([
        errorRoot,
        warningRoot,
        mentionsRoot,
        searchRoot,
        categoriesRoot,
        distPairsRoot
      ]);
      _isLoading = false;
      notifyListeners();
    });
  }

  void setColumnType(int col, String type) {
    if (type == ColumnType.attributes.name) {
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
      _saveSheetDataUseCase.saveLastSelectedCell(_selectionStart);
      mentionsRoot.row = _selectionStart.x;
      mentionsRoot.col = _selectionStart.y;
      populateTree([mentionsRoot]);
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
    saveAndCalculate();
  }

  void selectAll() {
    selectRange(0, 0, rowCount - 1, colCount - 1);
  }

  void populateCellNode(NodeStruct root) {
    int rowId = root.row!;
    int colId = root.col!;
    if (rowId >= rowCount || colId >= colCount) return;
    if (root.message == null) {
      if (root.instruction == SpreadsheetConstants.selectionMsg) {
        root.message =
            '${columnName(colId)}$rowId selected: ${table[rowId][colId]}';
      } else {
        root.message = '${columnName(colId)}$rowId: ${table[rowId][colId]}';
      }
    }
    root.newChildren = [];
    if (columnTypes[colId] == ColumnType.names.name ||
        columnTypes[colId] == ColumnType.filePath.name ||
        columnTypes[colId] == ColumnType.url.name) {
      root.newChildren!.add(
        NodeStruct(
          message: table[rowId][colId],
          cellWithName: CellWithName(row: rowId),
        ),
      );
      return;
    }
    for (CellWithName att in tableToAtt[rowId][colId]) {
      root.newChildren!.add(NodeStruct(cellWithName: att));
    }
  }

  void populateAttributeNode(NodeStruct root, CellWithName att) {
    if (attToRefFromAttColToCol.containsKey(att)) {
      root.newChildren!.add(
        NodeStruct(
          instruction: SpreadsheetConstants.refFromAttColMsg,
          cellWithName: att,
        ),
      );
    }
    if (attToRefFromDepColToCol.containsKey(att)) {
      root.newChildren!.add(
        NodeStruct(
          instruction: SpreadsheetConstants.refFromDepColMsg,
          cellWithName: att,
        ),
      );
    }
    if (att.row != all && att.col == all) {
      List<String> rowNames = [];
      for (final index in nameIndexes) {
        for (final name in tableToAtt[att.row][index]) {
          rowNames.add(name.name);
        }
      }
      root.message ??= 'Row ${att.row}: ${rowNames.join(', ')}';
      for (int colId = 0; colId < colCount; colId++) {
        if (table[att.row][colId].isNotEmpty) {
          root.newChildren!.add(
            NodeStruct(
              cellWithName: CellWithName(row: att.row, col: colId),
            ),
          );
        }
      }
    }
  }

  void populateRowNode(NodeStruct root) {
    int rowId = root.row!;
    root.message ??= worker.getRowName(rowId);
    for (int colId = 0; colId < colCount; colId++) {
      if (table[rowId][colId].isNotEmpty) {
        root.newChildren!.add(
          NodeStruct(
            cellWithName: CellWithName(row: rowId, col: colId),
          ),
        );
      }
    }
  }

  void populateColumnNode(NodeStruct root, CellWithName att) {
    
  }

  void populateNode(NodeStruct node, CellWithName att, {String? instruction}) {
    instruction ??= node.instruction;
    switch (instruction) {
      case SpreadsheetConstants.refFromAttColMsg:
        for (int pointerRowId in attToRefFromAttColToCol[att]!.keys) {
          node.newChildren!.add(
            NodeStruct(cellWithName: CellWithName(row: pointerRowId)),
          );
        }
        break;
      case SpreadsheetConstants.refFromDepColMsg:
        for (int pointerRowId in attToRefFromDepColToCol[att]!.keys) {
          node.newChildren!.add(
            NodeStruct(cellWithName: CellWithName(row: pointerRowId)),
          );
        }
        break;
      case SpreadsheetConstants.nodeAttributeMsg:
        populateAttributeNode(node, att);
        break;
      case SpreadsheetConstants.cell:
        populateCellNode(node, att.row, att.col);
        break;
      case SpreadsheetConstants.cycleDetected:
        node.onTap = (n) {
          int found = -1;
          for (int i = 0; i < n.newChildren!.length; i++) {
            final child = n.newChildren![i];
            if (_selectionStart.x == child.cellWithName!.row) {
              found = i;
              break;
            }
          }
          if (found == -1) {
            selectCell(n.newChildren![0].row!, 0);
          } else {
            selectCell(
              n.newChildren![(found + 1) % n.newChildren!.length].row!,
              0,
            );
          }
        };
      default:
        if (node.row != null) {
          if (node.col != null) {
            if (node.name != null) {
              throw UnimplementedError(
                  "CellWithName with name, row and col not implemented");
            } else {
              populateCellNode(node);
            }
          } else {
            if (node.name != null) {
              throw UnimplementedError(
                  "CellWithName with name and row not implemented");
            } else {
              populateRowNode(node);
            }
          }
        } else {
          if (node.col != null) {
            if (node.name != null) {
              populateAttributeNode(node, att);
            } else {
              populateColumnNode(node, att);
            }
          } else {
            if (node.name != null) {
              throw UnimplementedError(
                  "CellWithName with name but no row or col not implemented");
            } else {
              populateAttributeNode(node, att);
            }
          }
        }
        break;
    }
  }

  void populateTree(List<NodeStruct> roots) {
    // TODO keep same expansion if the user just moved, or even if there have been changes
    // List<int> newRowIndexes = [];
    // List<int> newColIndexes = [];
    // Map<String, String> newNameToOldName = {};
    var stack = [root];
    while (stack.isNotEmpty) {
      var node = stack.removeLast();
      if (node.newChildren == null) {
        node.newChildren = [];
        CellWithName att = node.cellWithName;
        if (att.row == all) {
          if (att.col != all) {
            if (att.name.isEmpty) {
              node.message = 'Column ${columnName(att.col)}';
              for (final attCol in colToAtt[att.col]!) {
                node.newChildren!.add(NodeStruct(cellWithName: attCol));
              }
            } else {
              populateAttribute(root, att);
            }
          }
        } else if (att.col == all) {
          if (att.name.isEmpty) {
            List<String> rowNames = [];
            for (final index in nameIndexes) {
              for (final name in tableToAtt[att.row][index]) {
                rowNames.add(name.name);
              }
            }
            root.message ??= 'Row ${att.row}: ${rowNames.join(', ')}';
            for (int colId = 0; colId < colCount; colId++) {
              if (table[att.row][colId].isNotEmpty) {
                root.newChildren!.add(
                  NodeStruct(
                    cellWithName: CellWithName(row: att.row, col: colId),
                  ),
                );
              }
            }
          } else {
            debugPrint("hey");
          }
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
    populateTree([node]);
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
