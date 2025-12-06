import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/usecases/get_sheet_data_usecase.dart';
import '../../domain/usecases/save_sheet_data_usecase.dart'; // Assume created
import '../../domain/entities/column_type.dart';

class SpreadsheetController extends ChangeNotifier {
  final GetSheetDataUseCase _getDataUseCase;

  // Data Storage
  final Map<String, String> _data = {};
  final Map<int, String> _columnTypes = {}; // Stores column types
  
  // Dimensions
  int _rowCount = 100; 
  int _colCount = 20;
  bool _isLoading = false;

  // Selection State
  Point<int>? _selectionStart;
  Point<int>? _selectionEnd;

  SpreadsheetController({required GetSheetDataUseCase getDataUseCase}) 
      : _getDataUseCase = getDataUseCase;

  // Getters
  int get rowCount => _rowCount;
  int get colCount => _colCount;
  bool get isLoading => _isLoading;

  // --- Data Loading ---
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cells = await _getDataUseCase.execute();
      for (var cell in cells) {
        _data['${cell.row}_${cell.col}'] = cell.content;
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Content Access ---
  String getContent(int row, int col) {
    return _data['${row}_${col}'] ?? ''; // Return empty string by default
  }

  void updateCell(int row, int col, String value) {
    _data['${row}_${col}'] = value;
    // TODO: Add debounce save logic here
    notifyListeners();
  }

  // --- Column Logic ---
  String getColumnType(int col) {
    return _columnTypes[col] ?? ColumnType.defaultType.name;
  }

  void setColumnType(int col, String typeName) {
    _columnTypes[col] = typeName;
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

  void pasteText(String text) {
    if (_selectionStart == null) return;
    
    // Start pasting from the top-left of the current selection
    int startRow = min(_selectionStart!.x, _selectionEnd?.x ?? _selectionStart!.x);
    int startCol = min(_selectionStart!.y, _selectionEnd?.y ?? _selectionStart!.y);

    final rows = text.split('\n');
    for (int r = 0; r < rows.length; r++) {
      final columns = rows[r].split('\t');
      for (int c = 0; c < columns.length; c++) {
        // Remove \r if present from Windows clipboards
        String val = columns[c].replaceAll('\r', '');
        updateCell(startRow + r, startCol + c, val);
      }
    }
  }

  void addRows(int count) {
    _rowCount += count;
    notifyListeners();
  }

  void addColumns(int count) {
    _colCount += count;
    notifyListeners();
  }
}