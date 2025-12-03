import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoadSheetDataSource {

  // ---- Save data for current spreadsheet ----
  Future<void> saveSpreadsheet(List<List<String>> table, List<String> columnTypes, String spreadsheetName) async {
    if (spreadsheetName.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    final data = {"table": table, "columnTypes": columnTypes};

    await prefs.setString("spreadsheet_$spreadsheetName", jsonEncode(data));
  }

  Future<void> clearAllPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ---- Load spreadsheet by name ----
  Future<void> loadSpreadsheet(String spreadsheetName) async {
    // await clearAllPrefs();
    String spreadsheetName = name.trim().toLowerCase();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      "last_opened_sheet",
      spreadsheetName,
    );

    final raw = prefs.getString("spreadsheet_$spreadsheetName");

    if (raw == null) {
      _saveExecutor.run(() async {
        getEverything();
      });
      return;
    }

    final decoded = jsonDecode(raw);

    // Restore table
    final storedGrid = (decoded["table"] as List)
        .map((row) => (row as List).map((v) => v.toString()).toList())
        .toList();

    table = List<List<String>>.generate(
      storedGrid.length,
      (r) => List<String>.filled(
        storedGrid[r].length,
        '',
        growable: true,
      ),
      growable: true,
    );
    for (int r = 0; r < storedGrid.length; r++) {
      for (int c = 0; c < storedGrid[r].length; c++) {
        table[r][c] = storedGrid[r][c];
      }
    }
    decreaseRowCount(rowCount - 1);
    decreaseColumnCount(colCount - 1);

    // Restore column types
    columnTypes = List<String>.from(decoded["columnTypes"] ?? []);

    _saveExecutor.run(() async {
      getEverything();
    });
  }
}