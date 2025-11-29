import 'package:shared_preferences/shared_preferences.dart';

class SpreadsheetRepository {
  // Handles the messy details of storage
  Future<String?> getLastOpenedSheetPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("last_opened_sheet");
  }

  Future<void> saveLastOpenedSheetPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("last_opened_sheet", path);
  }

  // Future<SpreadsheetData> loadSpreadsheet(String path) async {
  //   ... logic to read file and parse into objects ...
  // }
}