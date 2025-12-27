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
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/cell.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/instr_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/nodes_usecase.dart';
import 'package:trying_flutter/features/media_sorter/presentation/utils/side_menu_tree_builder.dart';

class SpreadsheetController extends ChangeNotifier {
  int saveDelayMs = 500;

  final GetSheetDataUseCase _getDataUseCase;
  final SaveSheetDataUseCase _saveSheetDataUseCase;
  final ParsePasteDataUseCase _parsePasteDataUseCase;
  final Map<String, ManageWaitingTasks<void>> _saveExecutors = {};
  final ManageWaitingTasks<AnalysisResult> _calculateExecutor =
      ManageWaitingTasks<AnalysisResult>();
  NodesUsecase nodesUsecase = NodesUsecase(AnalysisResult());
  late SideMenuTreeBuilder builder;

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

  SpreadsheetController({
    required GetSheetDataUseCase getDataUseCase,
    required SaveSheetDataUseCase saveSheetDataUseCase,
    required ParsePasteDataUseCase parsePasteDataUseCase,
  }) : _getDataUseCase = getDataUseCase,
       _saveSheetDataUseCase = saveSheetDataUseCase,
       _parsePasteDataUseCase = parsePasteDataUseCase {
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
      debugPrint(
        "Last opened sheet $sheetName not found in available sheets, adding it.",
      );
    }
    lastSelectedCells = await _getDataUseCase.getAllLastSelected(
      availableSheets,
    );

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

    if (availableSheets.contains(name)) {
      if (loadedSheetsData.containsKey(name)) {
        table = loadedSheetsData[name]!["table"] as List<List<String>>;
        columnTypes = loadedSheetsData[name]!["columnTypes"] as List<String>;
        _selectionStart = lastSelectedCells[name]!;
        _selectionEnd = lastSelectedCells[name]!;
      } else {
        _saveExecutors[name] = ManageWaitingTasks<void>();
        try {
          var (iTable, iColumnTypes) = await _getDataUseCase.loadSheet(name);
          table = iTable;
          columnTypes = iColumnTypes;
          if (init) {
            _selectionStart = await _getDataUseCase.getLastSelectedCell();
          } else {
            _selectionStart = lastSelectedCells[name]!;
          }
        } catch (e) {
          debugPrint("Error parsing sheet data for $name: $e");
          table = [];
          columnTypes = [];
          _selectionStart = Point(0, 0);
        }
      }
    } else {
      table = [];
      columnTypes = [];
      _selectionStart = Point(0, 0);
      availableSheets.add(name);
      _saveSheetDataUseCase.saveAllSheetNames(availableSheets);
      _saveExecutors[name] = ManageWaitingTasks<void>();
    }
    _selectionEnd = _selectionStart;
    loadedSheetsData[name] = {"table": table, "columnTypes": columnTypes};
    sheetName = name;
    _saveSheetDataUseCase.saveLastOpenedSheetName(name);
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
        await _saveSheetDataUseCase.saveSheet(sheetName, table, columnTypes);
        await Future.delayed(Duration(milliseconds: saveDelayMs));
      });
    }
    if (!calculate) {
      return;
    }
    _calculateExecutor.execute(
      () async {
        final calculateUsecase = CalculateUsecase(table, columnTypes);
        return await compute(
          runCalculator,
          calculateUsecase.getMessage(table, columnTypes),
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
        rowToAtt = result.rowToAtt;
        toMentioners = result.toMentioners;
        instrTable = result.instrTable;
        colToAtt = result.colToAtt;
        mentionsRoot.rowId = _selectionStart.x;
        mentionsRoot.colId = _selectionStart.y;
        
        // 2. Instantiate the Builder
        builder = SideMenuTreeBuilder(
          table: table,
          columnTypes: columnTypes,
          nodesUsecase: nodesUsecase,
          // Pass the specific maps the builder needs
          tableToAtt: tableToAtt,
          attToRefFromAttColToCol: attToRefFromAttColToCol,
          attToRefFromDepColToCol: attToRefFromDepColToCol, // Use local var if not in state yet, or controller var
          colToAtt: colToAtt,
          attToCol: attToCol,
          // Pass selection context
          selectionStart: _selectionStart,
          selectionEnd: _selectionEnd,
          onSelectCell: (r, c) => selectCell(r, c),
        );

        builder.populateTree([
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
        columnTypes[col] = type;
        decreaseColumnCount(col);
      }
    } else {
      increaseColumnCount(col);
      columnTypes[col] = type;
    }
    saveAndCalculate();
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
      mentionsRoot.rowId = _selectionStart.x;
      mentionsRoot.colId = _selectionStart.y;
      builder.populateTree([mentionsRoot]);
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

  void toggleNodeExpansion(NodeStruct node, bool isExpanded) {
    node.isExpanded = isExpanded;
    builder.populateTree([node]);
    notifyListeners();
  }

  String getColumnLabel(int col) {
    return nodesUsecase.getColumnLabel(col);
  }
}
