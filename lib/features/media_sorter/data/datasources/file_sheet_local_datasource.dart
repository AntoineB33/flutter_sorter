import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/i_file_sheet_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:trying_flutter/features/media_sorter/domain/constants/spreadsheet_constants.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/selection_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_progress_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:path/path.dart' as p;

class FileSheetLocalDataSource implements IFileSheetLocalDataSource {
  final SharedPreferences prefs;

  FileSheetLocalDataSource(this.prefs);

  @override
  Future<SelectionData> getLastSelection() async {
    final cellString = prefs.getString(
      SpreadsheetConstants.lastSelectedCellKey,
    );

    // 1. Handle the null case safely
    if (cellString == null) {
      // Throw a custom exception that the repository will expect
      throw CacheNotFoundException();
    }

    // 2. Wrap the parsing in a try-catch to handle corrupted data
    try {
      final Map<String, dynamic> decodedJson = jsonDecode(cellString);
      return SelectionData.fromJson(decodedJson);
    } on FormatException catch (e) {
      // Catch the corrupted JSON error and throw a custom architecture exception
      throw CacheParsingException(e);
    } catch (e) {
      // A fallback catch for any other unexpected model parsing errors
      throw CacheException(e);
    }
  }

  @override
  Future<void> saveLastSelection(SelectionData selection) async {
    final jsonString = jsonEncode(selection.toJson());
    final bool success = await prefs.setString(
      SpreadsheetConstants.lastSelectedCellKey,
      jsonString,
    );
    if (!success) {
      throw CacheException();
    }
  }

  @override
  Future<List<String>> recentSheetIds() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      // 1. Safely construct the path
      final filePath = p.join(
        directory.path,
        SpreadsheetConstants.folderName,
        SpreadsheetConstants.sheetsIndexFileName,
      );

      final file = File(filePath);

      // 2. Handle the "first run" gracefully without throwing
      if (!await file.exists()) {
        return [];
      }

      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // 3. Safe casting
      return List<String>.from(jsonList);
    } on FormatException catch (e) {
      // 4. Map to domain exception and preserve the stack/error
      throw CacheParsingException(e);
    } catch (e) {
      // 5. Catch-all that doesn't swallow the root cause
      throw CacheException(e);
    }
  }

  @override
  Future<void> saveRecentSheetIds(List<String> sheetIds) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      // 1. Safely construct the path
      final filePath = p.join(
        directory.path,
        SpreadsheetConstants.folderName,
        SpreadsheetConstants.sheetsIndexFileName,
      );

      final jsonString = jsonEncode(sheetIds);
      final tempFile = File('$filePath.tmp');
      await tempFile.writeAsString(jsonString, flush: true);
      await tempFile.rename(filePath);
    } on FileSystemException catch (e) {
      throw FileNotFoundException(e);
    } on FormatException catch (e) {
      throw CacheParsingException(e);
    } catch (e) {
      throw CacheException(e);
    }
  }

  Future<File> _getFile(String sheetId) async {
    final directory = await getApplicationDocumentsDirectory();

    // 1. Safely construct the path
    final filePath = p.join(
      directory.path,
      SpreadsheetConstants.folderName,
      SpreadsheetConstants.sheetsIndexFileName,
    );

    final file = File(filePath);

    await file.create(recursive: true);
    return file;
  }

  @override
  Future<SheetData> getSheet(String sheetId) async {
    final file = await _getFile(sheetId);
    try {
      if (!await file.exists()) {
        return SheetData.empty();
      }

      final jsonString = await file.readAsString();
      final Map<String, dynamic> jsonList = jsonDecode(jsonString);
      return SheetData.fromJson(jsonList);
    } on FormatException catch (e) {
      // 4. Map to domain exception and preserve the stack/error
      throw CacheParsingException(e);
    } catch (e) {
      // 5. Catch-all that doesn't swallow the root cause
      throw CacheException(e);
    }
  }

  @override
  Future<void> saveSheet(String sheetId, SheetData sheet) async {
    try {
        
      final directory = await getApplicationDocumentsDirectory();

      // 1. Safely construct the path
      final filePath = p.join(
        directory.path,
        SpreadsheetConstants.folderName,
        SpreadsheetConstants.sheetsIndexFileName,
      );
      final jsonString = jsonEncode(sheet.toJson());
      final tempFile = File('$filePath.tmp');
      await tempFile.writeAsString(jsonString, flush: true);
      await tempFile.rename(filePath);
    } on FileSystemException catch (e) {
      throw FileNotFoundException(e);
    } on FormatException catch (e) {
      throw CacheParsingException(e);
    } catch (e) {
      throw CacheException(e);
    }
  }

  @override
  Future<Map<String, SelectionData>> getAllLastSelected() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = p.join(
        directory.path,
        SpreadsheetConstants.folderName,
        SpreadsheetConstants.allLastSelectedFileName,
      );
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final Map<String, SelectionData> result = {};
      decoded.forEach((key, value) {
        result[key] = SelectionData.fromJson(value);
      });
      return result;
    } on FileSystemException catch (e) {
      throw FileNotFoundException(e);
    } on FormatException catch (e) {
      throw CacheParsingException(e);
    } catch (e) {
      throw CacheException(e);
    }
  }

  @override
  Future<void> saveAllLastSelected(
    Map<String, SelectionData> lastSelected,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = p.join(
        directory.path,
        SpreadsheetConstants.folderName,
        SpreadsheetConstants.allLastSelectedFileName,
      );
      final jsonString = jsonEncode(lastSelected);
      final tempFile = File('$filePath.tmp');
      await tempFile.writeAsString(jsonString, flush: true);
      await tempFile.rename(filePath);
    } on FormatException catch (e) {
      throw CacheParsingException(e);
    } catch (e) {
      throw CacheException(e);
    }
  }

  @override
  Future<Map<String, SortStatus>> getAllSortStatus() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = p.join(
        directory.path,
        SpreadsheetConstants.folderName,
        SpreadsheetConstants.allSortStatusFileName,
      );
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final Map<String, SortStatus> result = {};
      decoded.forEach((key, value) {
        result[key] = SortStatus.fromJson(value);
      });
      return result;
    } on FileSystemException catch (e) {
      throw FileNotFoundException(e);
    } on FormatException catch (e) {
      throw CacheParsingException(e);
    } catch (e) {
      throw CacheException(e);
    }
  }

  @override
  Future<void> saveAllSortStatus(
    Map<String, SortStatus> sortStatusBySheet,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = p.join(
        directory.path,
        SpreadsheetConstants.folderName,
        SpreadsheetConstants.allSortStatusFileName,
      );
      final jsonString = jsonEncode(sortStatusBySheet);
      final tempFile = File('$filePath.tmp');
      await tempFile.writeAsString(jsonString, flush: true);
      await tempFile.rename(filePath);
    } on FormatException catch (e) {
      throw CacheParsingException(e);
    } catch (e) {
      throw CacheException(e);
    }
  }

  @override
  Future<AnalysisResult> getAnalysisResult(String sheetId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/${SpreadsheetConstants.folderName}/analysis_$sheetId.json',
    );
    try {
      final jsonString = await file.readAsString();
      var decoded = jsonDecode(jsonString);
      return AnalysisResult.fromJson(decoded);
    } on FileSystemException catch (e) {
      throw FileNotFoundException(e);
    } on FormatException catch (e) {
      throw CacheParsingException(e);
    } catch (e) {
      throw CacheException(e);
    }
  }

  @override
  Future<void> saveAnalysisResult(
    String sheetId,
    AnalysisResult result,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = p.join(
        directory.path,
        SpreadsheetConstants.folderName,
        'analysis_$sheetId.json',
      );
      final jsonString = jsonEncode(result.toJson());
      final tempFile = File('$filePath.tmp');
      await tempFile.writeAsString(jsonString, flush: true);
      await tempFile.rename(filePath);
    } on FormatException catch (e) {
      throw CacheParsingException(e);
    } catch (e) {
      throw CacheException(e);
    }
  }

  @override
  Future<SortProgressData> getSortProgression(String sheetId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/${SpreadsheetConstants.folderName}/sort_progress_$sheetId.json',
    );
    try {
      final jsonString = await file.readAsString();
      var decoded = jsonDecode(jsonString);
      return SortProgressData.fromJson(decoded);
    } on FileSystemException catch (e) {
      throw FileNotFoundException(e);
    } on FormatException catch (e) {
      throw CacheParsingException(e);
    } catch (e) {
      throw CacheException(e);
    }
  }

  @override
  Future<void> saveSortProgression(
    String sheetId,
    SortProgressData progress,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = p.join(
        directory.path,
        SpreadsheetConstants.folderName,
        'sort_progress_$sheetId.json',
      );
      final jsonString = jsonEncode(progress.toJson());
      final tempFile = File('$filePath.tmp');
      await tempFile.writeAsString(jsonString, flush: true);
      await tempFile.rename(filePath);
    } on FormatException catch (e) {
      throw CacheParsingException(e);
    } catch (e) {
      throw CacheException(e);
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
      p.join(directory.path, SpreadsheetConstants.folderName)
    );
    if (await mediaSorterDir.exists()) {
      await mediaSorterDir.delete(recursive: true);
    }
  }
}
