import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/usecases/get_sheet_data_usecase.dart';
import '../../domain/usecases/save_sheet_data_usecase.dart'; // Assume created
import '../../domain/entities/column_type.dart';
import '../../domain/usecases/parse_paste_data_usecase.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/node_struct.dart';
import '../../domain/usecases/manage_waiting_tasks.dart';

class SpreadsheetController extends ChangeNotifier {
  final GetSheetDataUseCase _getDataUseCase;
  final SaveSheetDataUseCase _saveSheetDataUseCase;
  final ParsePasteDataUseCase _parsePasteDataUseCase;
  final ManageWaitingTasks _saveExecutor = ManageWaitingTasks();

  List<List<String>> table = [];
  List<String> columnTypes = [];
  String sheetName = "";
  int tableViewRows = 50;
  int tableViewCols = 50;

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
      // 1. Get the last opened sheet name
      sheetName = await _getDataUseCase.getLastOpenedSheetName();

      // 2. Load the actual data
      Map<String, dynamic> mapData = await _getDataUseCase.loadSheet(sheetName);
      table = List<List<String>>.from(mapData["table"] ?? []);
      columnTypes = List<String>.from(mapData["columnTypes"] ?? []);
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
    _saveExecutor.execute(() async {
      await _saveSheetDataUseCase.saveSheet(sheetName, table, columnTypes);
      await Future.delayed(Duration(milliseconds: 100)); // Debounce
    });
  }

  // --- Column Logic ---
  String getColumnType(int col) {
    return columnTypes[col];
  }

  void setColumnType(int col, String typeName) {
    columnTypes[col] = typeName;
    notifyListeners();
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
