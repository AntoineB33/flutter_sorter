import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/i_file_sheet_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';

class FileSheetLocalDataSource implements IFileSheetLocalDataSource {
  @override
  Future<SelectionData> getLastSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final cellString = prefs.getString(
      SpreadsheetConstants.lastSelectedCellKey,
    );
    return SelectionData.fromJson(jsonDecode(cellString!));
  }

  @override
  Future<void> saveLastSelection(SelectionData selection) async {
    await Future.delayed(
      const Duration(milliseconds: SpreadsheetConstants.debugDelayMs),
    );
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(selection.toJson());
    await prefs.setString(SpreadsheetConstants.lastSelectedCellKey, jsonString);
  }

  @override
  Future<String?> getLastOpenedSheetName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SpreadsheetConstants.lastOpenedSheetNameKey);
  }

  @override
  Future<void> saveLastOpenedSheetName(String sheetName) async {
    await Future.delayed(
      const Duration(milliseconds: SpreadsheetConstants.debugDelayMs),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      SpreadsheetConstants.lastOpenedSheetNameKey,
      sheetName,
    );
  }

  @override
  Future<List<String>> getAllSheetNames() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/${SpreadsheetConstants.folderName}/${SpreadsheetConstants.sheetsIndexFileName}',
    );
    try {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<String> sheetNames = jsonList.cast<String>();
      return sheetNames;
    } on FileSystemException catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveAllSheetNames(List<String> sheetNames) async {
    await Future.delayed(
      const Duration(milliseconds: SpreadsheetConstants.debugDelayMs),
    );
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/${SpreadsheetConstants.folderName}/${SpreadsheetConstants.sheetsIndexFileName}',
    );
    await file.create(recursive: true);
    final jsonString = jsonEncode(sheetNames);
    final tempFile = File('${file.path}.tmp');
    await tempFile.writeAsString(jsonString, flush: true);
    await tempFile.rename(file.path);
  }

  Future<File> _getFile(String sheetName) async {
    final directory = await getApplicationDocumentsDirectory();
    // Sanitize filename to prevent path traversal
    final file = File(
      '${directory.path}/${SpreadsheetConstants.folderName}/sheet_$sheetName.json',
    );
    await file.create(recursive: true);
    return file;
  }

  @override
  Future<SheetData> getSheet(String sheetName) async {
    final file = await _getFile(sheetName);
    try {
      final jsonString = await file.readAsString();
      var decoded = jsonDecode(jsonString);
      return SheetData.fromJson(decoded);
    } catch (e) {
      debugPrint("Error decoding JSON for sheet $sheetName: $e");
      return SheetData.empty();
    }
  }

  @override
  Future<void> saveSheet(String sheetName, SheetData sheet) async {
    try {
      await Future.delayed(
        const Duration(milliseconds: SpreadsheetConstants.debugDelayMs),
      );
      
      final file = await _getFile(sheetName);
      final jsonString = jsonEncode(sheet.toJson());
      final tempFile = File('${file.path}.tmp');
      await tempFile.writeAsString(jsonString, flush: true);
      await tempFile.rename(file.path);
      
    } catch (e) {
      throw Exception("Error saving sheet: $e");
    }
  }
  
  @override
  Future<Map<String, SelectionData>> getAllLastSelected() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/${SpreadsheetConstants.folderName}/${SpreadsheetConstants.allLastSelectedFileName}',
    );
    try {
      final jsonString = await file.readAsString();
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final Map<String, SelectionData> result = {};
      decoded.forEach((key, value) {
        result[key] = SelectionData.fromJson(value);
      });
      return result;
    } catch (e) {
      debugPrint("Error reading all last selected cells: $e");
      return {};
    }
  }

  @override
  Future<void> saveAllLastSelected(
    Map<String, SelectionData> lastSelected,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: SpreadsheetConstants.debugDelayMs),
    );
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${SpreadsheetConstants.folderName}/${SpreadsheetConstants.allLastSelectedFileName}');
    await file.create(recursive: true);
    final jsonString = jsonEncode(lastSelected);
    final tempFile = File('${file.path}.tmp');
    await tempFile.writeAsString(jsonString, flush: true);
    await tempFile.rename(file.path);
  }

  @override
  Future<Map<String, SortStatus>> getAllSortStatus() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/${SpreadsheetConstants.folderName}/${SpreadsheetConstants.allSortStatusFileName}',
    );
    try {
      final jsonString = await file.readAsString();
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final Map<String, SortStatus> result = {};
      decoded.forEach((key, value) {
        result[key] = SortStatus.fromJson(value);
      });
      return result;
    } catch (e) {
      debugPrint("Error reading all sort status: $e");
      return {};
    }
  }

  @override
  Future<void> saveAllSortStatus(Map<String, SortStatus> sortStatusBySheet) async {
    await Future.delayed(
      const Duration(milliseconds: SpreadsheetConstants.debugDelayMs),
    );
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${SpreadsheetConstants.folderName}/${SpreadsheetConstants.allSortStatusFileName}');
    await file.create(recursive: true);
    final jsonString = jsonEncode(sortStatusBySheet);
    final tempFile = File('${file.path}.tmp');
    await tempFile.writeAsString(jsonString, flush: true);
    await tempFile.rename(file.path);
  }

  @override
  Future<AnalysisResult> getAnalysisResult(String sheetName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/${SpreadsheetConstants.folderName}/analysis_$sheetName.json',
    );
    try {
      final jsonString = await file.readAsString();
      var decoded = jsonDecode(jsonString);
      return AnalysisResult.fromJson(decoded);
    } catch (e) {
      debugPrint("Error decoding JSON for analysis result of sheet $sheetName: $e");
      return AnalysisResult.empty();
    }
  }

  @override
  Future<void> saveAnalysisResult(String sheetName, AnalysisResult result) async {
    try {
      await Future.delayed(
        const Duration(milliseconds: SpreadsheetConstants.debugDelayMs),
      );
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/${SpreadsheetConstants.folderName}/analysis_$sheetName.json',
      );
      await file.create(recursive: true);
      final jsonString = jsonEncode(result.toJson());
      final tempFile = File('${file.path}.tmp');
      await tempFile.writeAsString(jsonString, flush: true);
      await tempFile.rename(file.path);
    } catch (e) {
      throw Exception("Error saving analysis result: $e");
    }
  }

  @override
  Future<void> clearAllData() async {
    // 1. Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SpreadsheetConstants.lastOpenedSheetNameKey);
    await prefs.remove(SpreadsheetConstants.lastSelectedCellKey);

    // 2. Get the Documents Directory
    final directory = await getApplicationDocumentsDirectory();

    // 3. Delete the 'media_sorter' folder (contains sheets_index.json)
    final mediaSorterDir = Directory(
      '${directory.path}/${SpreadsheetConstants.folderName}',
    );
    if (await mediaSorterDir.exists()) {
      await mediaSorterDir.delete(recursive: true);
    }
  }
}
