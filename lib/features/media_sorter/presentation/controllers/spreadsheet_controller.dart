import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/calculate_usecase.dart';
import '../../domain/usecases/get_sheet_data_usecase.dart';
import '../../domain/usecases/save_sheet_data_usecase.dart'; // Assume created
import '../../domain/entities/column_type.dart';
import '../../domain/usecases/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import '../../domain/usecases/manage_waiting_tasks.dart';
import 'package:logging/logging.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/isolate_messages.dart';

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

  final NodeStruct mentionsRoot = NodeStruct(message: "Root");

  // Dimensions
  bool _isLoading = false;

  // Selection State
  Point<int>? _selectionStart;
  Point<int>? _selectionEnd;

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
        Map<String, dynamic> mapData = await _getDataUseCase.loadSheet(name);
        try {
          final rawTable = mapData["table"] as List?;
          final rawColumnTypes = mapData["columnTypes"] as List?;
          table = rawTable?.map((row) {
            // Convert each row (which is a List) into a List<String>
            return (row as List).map((cell) => cell.toString()).toList();
          }).toList() ?? [];
          columnTypes = rawColumnTypes?.map((type) => type.toString()).toList() ?? [];
        } catch (e) {
          print("Error parsing sheet data for $name: $e");
        }
      }
    } else {
      table = [];
      columnTypes = [];
      availableSheets.add(name);
      availableSheetsChanged = true;
    }
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
    final calculateUsecase = CalculateUsecase(table, columnTypes);
    
    _calculateExecutor.execute(() async {
      result = await compute(
        SpreadsheetController.runCalculator,
        calculateUsecase.getMessage(table, columnTypes)
      );
    });
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

  Future<void> saveAndCalculate() async {
    _saveExecutors[sheetName]!.execute(() async {
      await _saveSheetDataUseCase.saveSheet(sheetName, table, columnTypes);
      await Future.delayed(Duration(milliseconds: saveDelayMs));
    });
    _calculateExecutor.execute(() async {
      final calculateUsecase = CalculateUsecase(table, columnTypes);
      result = await compute(
        runCalculator,
        calculateUsecase.getMessage(table, columnTypes),
      );
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
  void selectCell(int row, int col) {
    _selectionStart = Point(row, col);
    _selectionEnd = Point(row, col);
    notifyListeners();
  }

  void selectRange(int startRow, int startCol, int endRow, int endCol) {
    _selectionStart = Point(startRow, startCol);
    _selectionEnd = Point(endRow, endCol);
    notifyListeners();
  }

  bool isCellSelected(int row, int col) {
    if (_selectionStart == null || _selectionEnd == null) return false;

    final startRow = min(_selectionStart!.x, _selectionEnd!.x);
    final endRow = max(_selectionStart!.x, _selectionEnd!.x);
    final startCol = min(_selectionStart!.y, _selectionEnd!.y);
    final endCol = max(_selectionStart!.y, _selectionEnd!.y);

    return row >= startRow && row <= endRow && col >= startCol && col <= endCol;
  }

  // --- Clipboard Logic ---
  Future<String?> copySelectionToClipboard() async {
    if (_selectionStart == null || _selectionEnd == null) return null;

    final startRow = min(_selectionStart!.x, _selectionEnd!.x);
    final endRow = max(_selectionStart!.x, _selectionEnd!.x);
    final startCol = min(_selectionStart!.y, _selectionEnd!.y);
    final endCol = max(_selectionStart!.y, _selectionEnd!.y);

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
    if (data?.text == null || _selectionStart == null) return;

    // 1. Delegate Logic to UseCase
    // We normalize selection to ensure we paste from top-left
    int startRow = min(
      _selectionStart!.x,
      _selectionEnd?.x ?? _selectionStart!.x,
    );
    int startCol = min(
      _selectionStart!.y,
      _selectionEnd?.y ?? _selectionStart!.y,
    );

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
}
