import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SpreadsheetData {
  int _rows;
  int _cols;
  late List<List<String>> _cells;

  SpreadsheetData({int initialRows = 20, int initialCols = 10})
      : _rows = initialRows,
        _cols = initialCols {
    _cells = List.generate(
      _rows,
      (_) => List.generate(_cols, (_) => ''),
    );
  }

  int get rowCount => _rows;
  int get colCount => _cols;

  void _ensureSize(int row, int col) {
    if (row > _rows) {
      final rowsToAdd = row - _rows;
      for (int i = 0; i < rowsToAdd; i++) {
        _cells.add(List.generate(_cols, (_) => ''));
      }
      _rows = row;
    }
    if (col > _cols) {
      final colsToAdd = col - _cols;
      for (final rowList in _cells) {
        rowList.addAll(List.generate(colsToAdd, (_) => ''));
      }
      _cols = col;
    }
  }

  String getCell(int row, int col) {
    if (row < 1 || col < 1 || row > _rows || col > _cols) return '';
    return _cells[row - 1][col - 1];
  }

  void setCell(int row, int col, String value) {
    _ensureSize(row, col);
    _cells[row - 1][col - 1] = value;
  }

  void addRow() {
    _rows += 1;
    _cells.add(List.generate(_cols, (_) => ''));
  }

  void addColumn() {
    _cols += 1;
    for (final row in _cells) {
      row.add('');
    }
  }

  void clearAll() {
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        _cells[r][c] = '';
      }
    }
  }

  /// Returns Excel-style labels: A, B, ..., Z, AA, AB, ...
  String columnLabel(int col) {
    int n = col;
    final buffer = StringBuffer();
    while (n > 0) {
      n--; // 1-based to 0-based
      final charCode = 'A'.codeUnitAt(0) + (n % 26);
      buffer.writeCharCode(charCode);
      n ~/= 26;
    }
    return buffer.toString().split('').reversed.join();
  }

  /// Converts the spreadsheet to a JSON string.
  String toJsonString() {
    return jsonEncode({
      'rows': _rows,
      'cols': _cols,
      'cells': _cells,
    });
  }

  /// Reconstructs a spreadsheet from JSON.
  static SpreadsheetData fromJsonString(String jsonString) {
    final map = jsonDecode(jsonString);
    final data = SpreadsheetData(
      initialRows: map['rows'],
      initialCols: map['cols'],
    );
    final cells = (map['cells'] as List)
        .map<List<String>>((row) => List<String>.from(row))
        .toList();
    data._cells = cells;
    return data;
  }

  /// Saves spreadsheet to local storage.
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spreadsheet_data', toJsonString());
  }

  /// Loads spreadsheet from local storage, or returns null if none saved.
  static Future<SpreadsheetData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('spreadsheet_data');
    if (jsonString == null) return null;
    return fromJsonString(jsonString);
  }
}
