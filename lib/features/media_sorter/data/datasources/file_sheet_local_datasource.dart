import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:trying_flutter/features/media_sorter/domain/datasources/i_file_sheet_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class FileSheetLocalDataSource implements IFileSheetLocalDataSource {
  Future<String> getLastOpenedSheetName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastOpenedSheetName') ?? "";
  }

  Future<void> saveLastOpenedSheetName(String sheetName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastOpenedSheetName', sheetName);
  }

  Future<List<String>> getAllSheetNames() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/media_sorter/sheets_index.json');
    await file.parent.create(recursive: true);
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
    await file.parent.create(recursive: true);
    final jsonString = jsonEncode(sheetNames);
    await file.writeAsString(jsonString);
  }
  
  Future<File> _getFile(String sheetName) async {
    final directory = await getApplicationDocumentsDirectory();
    // Sanitize filename to prevent path traversal
    final safeName = sheetName.replaceAll(RegExp(r'[^\w\s]+'), ''); 
    return File('${directory.path}/sheet_$safeName.json');
  }

  @override
  Future<Map<String, dynamic>> getSheet(String sheetName) async {
    final file = await _getFile(sheetName);
    Map<String, dynamic> emptyData = {};
    if (!await file.exists()) {
      return emptyData;
    }

    final jsonString = await file.readAsString();
    Map<String, dynamic> decoded = {};
    try {
      decoded = jsonDecode(jsonString);
    } catch (e) {
      debugPrint("Error decoding JSON for sheet $sheetName: $e");
    }
    return decoded;
  }

  @override
  Future<void> saveSheet(String sheetName, Map<String, dynamic> data) async {
    try {
      final file = await _getFile(sheetName);
      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);
    } catch (e) {
      throw Exception("Error saving sheet: $e");
    }
  }

  Future<void> clearAllData() async {
    // 1. Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lastOpenedSheetName');

    // 2. Get the Documents Directory
    final directory = await getApplicationDocumentsDirectory();

    // 3. Delete the 'media_sorter' folder (contains sheets_index.json)
    final mediaSorterDir = Directory('${directory.path}/media_sorter');
    if (await mediaSorterDir.exists()) {
      await mediaSorterDir.delete(recursive: true);
    }

    // 4. Delete individual sheet files (sheet_*.json)
    // Note: Your _getFile method saves these in the root directory, 
    // so we must find and delete them manually.
    final List<FileSystemEntity> entities = await directory.list().toList();
    for (final entity in entities) {
      if (entity is File) {
        // Extract the filename from the path
        final filename = entity.uri.pathSegments.last;
        
        // Check if it matches your naming convention
        if (filename.startsWith('sheet_') && filename.endsWith('.json')) {
          await entity.delete();
        }
      }
    }
  }
}