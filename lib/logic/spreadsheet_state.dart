import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../data/models/cell.dart';
import '../data/models/node_struct.dart';

class SpreadsheetState extends ChangeNotifier {
  late final List<List<Cell>> _grid;
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
  }

  List<List<Cell>> get grid => _grid;
  int get rowCount => _grid.length;
  int get colCount => _grid[0].length;

  String getColumnType(int col) => _columnTypes[col] ?? 'Default';

  Cell? _selectedCell;
  Cell? get selectedCell => _selectedCell;

  // Select a cell
  void selectCell(int row, int col) {
    _selectedCell = _grid[row][col];
    _selectionStart = _selectedCell;
    _selectionEnd = _selectedCell;
    notifyListeners();
  }
  
  void selectRange(int startRow, int startCol, int endRow, int endCol) {
    _selectionStart = _grid[startRow][startCol];
    _selectionEnd = _grid[endRow][endCol];
    _selectedCell = _selectionStart; // anchor
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

  // Update the value of a cell
  void updateCell(int row, int col, String newValue) {
    _grid[row][col] = _grid[row][col].copyWith(value: newValue);
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
    if (_selectedCell == null) return;

    final startRow = _selectedCell!.row;
    final startCol = _selectedCell!.col;

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

  void setColumnType(int col, String type) {
    if (col >= 1 && col <= colCount) {
      _columnTypes[col] = type;
    }
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