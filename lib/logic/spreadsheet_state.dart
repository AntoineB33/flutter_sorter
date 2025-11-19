import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../data/models/cell.dart';
import '../data/models/node_struct.dart';
import '../data/models/column_type.dart';

class SpreadsheetState extends ChangeNotifier {
  String spreadsheetName = "";
  late List<List<Cell>> _grid;
  Map<int, String> _columnTypes = {};
  NodeStruct? errorRoot;
  NodeStruct? warningRoot;
  final NodeStruct mentionsRoot = NodeStruct(message: 'Current selection');
  final NodeStruct searchRoot = NodeStruct(message: 'Search results');
  final NodeStruct categoriesRoot = NodeStruct(message: 'Categories');
  final NodeStruct distPairsRoot = NodeStruct(message: 'Distance Pairs');

  Cell? _selectionStart;
  Cell? _selectionEnd;

  Cell? get selectionStart => _selectionStart;
  Cell? get selectionEnd => _selectionEnd;

  bool get hasSelectionRange =>
      _selectionStart != null && _selectionEnd != null;



  SpreadsheetState({int rows = 30, int cols = 10}) {
    _grid = List.generate(
      rows,
      (r) => List.generate(
        cols,
        (c) => Cell(row: r, col: c, value: ''),
      ),
    );
    _loadLastOpenedSheet();   // <--- Add this
  }

  Future<void> _loadLastOpenedSheet() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString("last_opened_sheet");

    if (last != null && last.trim().isNotEmpty) {
      await loadSpreadsheet(last);
    }
  }

  List<List<Cell>> get grid => _grid;
  int get rowCount => _grid.length;
  int get colCount => _grid[0].length;

  String getColumnType(int col) => _columnTypes[col] ?? ColumnType.defaultType.name;

  // Select a cell
  void selectCell(int row, int col) {
    _selectionStart = _grid[row][col];
    _selectionEnd = _selectionStart;
    notifyListeners();
  }
  
  void selectRange(int startRow, int startCol, int endRow, int endCol) {
    _selectionStart = _grid[startRow][startCol];
    _selectionEnd = _grid[endRow][endCol];
    notifyListeners();
  }
  
  bool isCellSelected(int row, int col) {
    if (!hasSelectionRange) return false;

    final r1 = _selectionStart!.row;
    final c1 = _selectionStart!.col;
    final r2 = _selectionEnd!.row;
    final c2 = _selectionEnd!.col;

    return row >= r1 &&
          row <= r2 &&
          col >= c1 &&
          col <= c2;
  }

  // ---- Save data for current spreadsheet ----
  Future<void> saveSpreadsheet() async {
    if (spreadsheetName.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    final data = {
      "grid": _grid.map((row) => row.map((c) => c.value).toList()).toList(),
      "types": _columnTypes,
    };

    await prefs.setString("spreadsheet_$spreadsheetName", jsonEncode(data));
  }

  // ---- Load spreadsheet by name ----
  Future<void> loadSpreadsheet(String name) async {
    spreadsheetName = name.trim().toLowerCase();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("last_opened_sheet", spreadsheetName);   // <--- Add this

    final raw = prefs.getString("spreadsheet_$spreadsheetName");

    if (raw == null) {
      // No existing spreadsheet → create empty grid
      _grid = List.generate(
        rowCount,
        (r) => List.generate(
          colCount,
          (c) => Cell(row: r, col: c, value: ''),
        ),
      );
      _columnTypes = {};
      notifyListeners();
      return;
    }

    final decoded = jsonDecode(raw);

    // Restore grid
    final storedGrid = (decoded["grid"] as List)
        .map((row) => (row as List).map((v) => v.toString()).toList())
        .toList();

    for (int r = 0; r < storedGrid.length; r++) {
      for (int c = 0; c < storedGrid[r].length; c++) {
        _grid[r][c] = _grid[r][c].copyWith(value: storedGrid[r][c]);
      }
    }

    // Restore column types
    _columnTypes = Map<int, String>.from(decoded["types"] ?? {});

    notifyListeners();
  }

  // ---- Call save on each update ----
  @override
  void updateCell(int row, int col, String newValue) {
    _grid[row][col] = _grid[row][col].copyWith(value: newValue);
    saveSpreadsheet();     // <-- Auto-save
    notifyListeners();
  }

  // What to display in the side menu
  String get selectedCellInfo {
    if (!hasSelectionRange) {
      return "No selection";
    }

    final r1 = selectionStart!.row + 1;
    final c1 = columnName(selectionStart!.col);
    final r2 = selectionEnd!.row + 1;
    final c2 = columnName(selectionEnd!.col);

    return "Selected range: $c1$r1 → $c2$r2";
  }


  void pasteText(String rawText) {
    if (_selectionStart == null) return;

    final startRow = _selectionStart!.row;
    final startCol = _selectionStart!.col;

    // Parse TSV (tab-separated values)
    final rows = rawText
        .trimRight()
        .split('\n')
        .map((r) => r.split('\t'))
        .toList();

    for (int r = 0; r < rows.length; r++) {
      for (int c = 0; c < rows[r].length; c++) {
        final targetRow = startRow + r;
        final targetCol = startCol + c;

        // Prevent overflow
        if (targetRow >= _grid.length || targetCol >= _grid[0].length) continue;

        updateCell(targetRow, targetCol, rows[r][c]);
      }
    }
    
    notifyListeners();
  }
  
  String columnName(int index) {
    index++; 
    String name = "";
    while (index > 0) {
      int rem = (index - 1) % 26;
      name = String.fromCharCode(65 + rem) + name;
      index = (index - 1) ~/ 26;
    }
    return name;
  }

  Map<int, String> get columnTypes => _columnTypes;

  @override
  void setColumnType(int col, String type) {
    _columnTypes[col] = type;
    if (type == ColumnType.defaultType.name) {
      _columnTypes.remove(col);
    }
    saveSpreadsheet();     // <-- Auto-save
    notifyListeners();
  }

  Future<String?> copySelectionToClipboard() async {
    if (!hasSelectionRange) return null;

    final r1 = selectionStart!.row;
    final c1 = selectionStart!.col;
    final r2 = selectionEnd!.row;
    final c2 = selectionEnd!.col;

    final buffer = StringBuffer();

    for (int r = r1; r <= r2; r++) {
      final rowValues = <String>[];
      for (int c = c1; c <= c2; c++) {
        rowValues.add(_grid[r][c].value);
      }
      buffer.writeln(rowValues.join('\t')); // TSV format
    }

    final text = buffer.toString().trimRight();
    await Clipboard.setData(ClipboardData(text: text));
    return text;
  }
  
}