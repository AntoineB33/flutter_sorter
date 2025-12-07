import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:trying_flutter/features/media_sorter/domain/datasources/sheet_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileSheetLocalDataSource implements SheetLocalDataSource {
  Future<String> getLastOpenedSheetName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastOpenedSheetName') ?? "";
  }
  
  Future<File> _getFile(String sheetName) async {
    final directory = await getApplicationDocumentsDirectory();
    // Sanitize filename to prevent path traversal
    final safeName = sheetName.replaceAll(RegExp(r'[^\w\s]+'), ''); 
    return File('${directory.path}/sheet_$safeName.json');
  }

  @override
  Future<(List<List<String>>, List<String>)> getSheet(String sheetName) async {
    try {
      final file = await _getFile(sheetName);
      List<List<String>> emptyData = [];
      List<String> emptyColumnTypes = [];
      if (!await file.exists()) {
        return (emptyData, emptyColumnTypes);
      }

      final jsonString = await file.readAsString();
      final List<dynamic> decoded = jsonDecode(jsonString);
      return (data, columnTypes);
    } catch (e) {
      throw Exception("Error loading sheet: $e");
    }
  }

  @override
  Future<void> saveSheet(String sheetName, (List<List<String>>, List<String>) data) async {
    try {
      final file = await _getFile(sheetName);
      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);
    } catch (e) {
      throw Exception("Error saving sheet: $e");
    }
  }
}