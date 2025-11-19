import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cell.dart';

class SpreadsheetRepository {
  static const String _lastOpenedKey = 'last_opened_sheet';
  static const String _spreadsheetPrefix = 'spreadsheet_';

  /// Retrieves the name of the last opened spreadsheet, if any.
  Future<String?> getLastOpenedSheetName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_lastOpenedKey);
    return (name != null && name.trim().isNotEmpty) ? name : null;
  }

  /// Saves the name of the currently active spreadsheet as the "last opened".
  Future<void> saveLastOpenedSheetName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastOpenedKey, name.trim().toLowerCase());
  }

  /// Loads the raw data for a spreadsheet by name.
  /// Returns [null] if no saved data exists for this name.
  Future<Map<String, dynamic>?> loadSpreadsheetData(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _generateKey(name);
    final raw = prefs.getString(key);

    if (raw == null) return null;

    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      // Handle potential corruption or legacy format issues
      return null;
    }
  }

  /// Serializes and saves the current grid and column configuration.
  Future<void> saveSpreadsheet(
    String name,
    List<List<Cell>> grid,
    Map<int, String> columnTypes,
  ) async {
    if (name.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final key = _generateKey(name);

    // Serialize the grid: Convert List<List<Cell>> to List<List<String>>
    final gridData = grid
        .map((row) => row.map((cell) => cell.value).toList())
        .toList();

    final data = {
      "grid": gridData,
      "types": columnTypes,
    };

    await prefs.setString(key, jsonEncode(data));
  }

  /// Helper to ensure consistent key naming
  String _generateKey(String name) {
    return '$_spreadsheetPrefix${name.trim().toLowerCase()}';
  }
}