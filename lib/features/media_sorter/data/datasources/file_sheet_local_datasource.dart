import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:trying_flutter/features/media_sorter/domain/datasources/i_file_sheet_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    if (!await file.exists()) {
      return [];
    }
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(jsonString);
    final List<String> sheetNames = jsonList.cast<String>();
    return sheetNames;
  }

  Future<void> saveAllSheetNames(List<String> sheetNames) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/media_sorter/sheets_index.json');
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
      print("Error decoding JSON for sheet $sheetName: $e");
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
}