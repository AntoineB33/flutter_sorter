import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/i_file_sheet_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_model.dart';

class FileSheetLocalDataSource implements IFileSheetLocalDataSource {
  Future<Map<String, int>> getLastSelectedCell() async {
    final prefs = await SharedPreferences.getInstance();
    final cellString = prefs.getString('lastSelectedCell');
    if (cellString == null) {
      return {"x": 0, "y": 0};
    }
    final Map<String, dynamic> cellMap = jsonDecode(cellString);
    return {"x": cellMap['x'] as int, "y": cellMap['y'] as int};
  }

  Future<void> saveLastSelectedCell(Map<String, int> cell) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSelectedCell', jsonEncode(cell));
  }

  Future<String> getLastOpenedSheetName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastOpenedSheetName') ?? SpreadsheetConstants.noSPNameFound;
  }

  Future<void> saveLastOpenedSheetName(String sheetName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastOpenedSheetName', sheetName);
  }

  Future<List<String>> getAllSheetNames() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/media_sorter/sheets_index.json');
    await file.create(recursive: true);
    try {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<String> sheetNames = jsonList.cast<String>();
      return sheetNames;
    } catch (e) {
      debugPrint("Error reading sheet names: $e");
      return [];
    }
  }

  Future<void> saveAllSheetNames(List<String> sheetNames) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/media_sorter/sheets_index.json');
    await file.create(recursive: true);
    final jsonString = jsonEncode(sheetNames);
    await file.writeAsString(jsonString);
  }

  Future<File> _getFile(String sheetName) async {
    final directory = await getApplicationDocumentsDirectory();
    // Sanitize filename to prevent path traversal
    final safeName = sheetName.replaceAll(RegExp(r'[^\w\s]+'), '');
    final file = File('${directory.path}/media_sorter/sheet_$safeName.json');
    await file.create(recursive: true);
    return file;
  }

  @override
  Future<SheetModel> getSheet(String sheetName) async {
    final file = await _getFile(sheetName);
    final jsonString = await file.readAsString();
    Map<String, dynamic> decoded = {};
    try {
      decoded = jsonDecode(jsonString);
    } catch (e) {
      debugPrint("Error decoding JSON for sheet $sheetName: $e");
    }
    return SheetModel.fromJson(decoded);
  }

  @override
  Future<void> saveSheet(String sheetName, SheetModel sheet) async {
    try {
      final file = await _getFile(sheetName);
      final jsonString = jsonEncode(sheet.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      throw Exception("Error saving sheet: $e");
    }
  }

  Future<Map<String, Map<String, int>>> getAllLastSelected() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/media_sorter/all_last_selected.json');
    await file.create(recursive: true);
    try {
      final jsonString = await file.readAsString();
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final Map<String, Map<String, int>> result = decoded.map((key, value) {
        final mapValue = (value as Map).map(
          (k, v) => MapEntry(k.toString(), v as int),
        );
        return MapEntry(key, mapValue);
      });
      return result;
    } catch (e) {
      debugPrint("Error reading all last selected cells: $e");
      return {};
    }
  }

  Future<void> saveAllLastSelected(
    Map<String, Map<String, int>> lastSelected,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/media_sorter/all_last_selected.json');
    await file.create(recursive: true);
    final jsonString = jsonEncode(lastSelected);
    await file.writeAsString(jsonString);
  }

  Future<void> clearAllData() async {
    // 1. Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lastOpenedSheetName');
    await prefs.remove('lastSelectedCell');

    // 2. Get the Documents Directory
    final directory = await getApplicationDocumentsDirectory();

    // 3. Delete the 'media_sorter' folder (contains sheets_index.json)
    final mediaSorterDir = Directory('${directory.path}/media_sorter');
    if (await mediaSorterDir.exists()) {
      await mediaSorterDir.delete(recursive: true);
    }
  }
}
