import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SpreadsheetLocalDataSource {
  // Ideally, SharedPreferences should be injected here via a Service or DI
  
  Future<void> saveSpreadsheetData(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("spreadsheet_$key", jsonEncode(data));
  }
}