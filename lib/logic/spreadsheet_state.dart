import 'package:flutter/material.dart';
import '../data/models/cell.dart';
import '../data/models/node_struct.dart';

class SpreadsheetState extends ChangeNotifier {
  late final List<List<Cell>> _grid;
  NodeStruct? errorRoot;
  NodeStruct? warningRoot;
  final NodeStruct mentionsRoot = NodeStruct(message: 'Current selection');
  final NodeStruct searchRoot = NodeStruct(message: 'Search results');
  final NodeStruct categoriesRoot = NodeStruct(message: 'Categories');
  final NodeStruct distPairsRoot = NodeStruct(message: 'Distance Pairs');

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

  Cell? _selectedCell;
  Cell? get selectedCell => _selectedCell;

  // Select a cell
  void selectCell(int row, int col) {
    _selectedCell = _grid[row][col];
    notifyListeners();
  }

  // Update the value of a cell
  void updateCell(int row, int col, String newValue) {
    _grid[row][col] = _grid[row][col].copyWith(value: newValue);
    notifyListeners();
  }

  // What to display in the side menu
  String get selectedCellInfo {
    if (_selectedCell == null) return "No cell selected";
    return "Cell (${_selectedCell!.row}, ${_selectedCell!.col})\n"
           "Value: ${_selectedCell!.value}";
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
}