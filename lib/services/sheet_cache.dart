import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SheetCache {
  static const _prefix = 'sheet_cache_';

  Future<void> saveSheet(String spreadsheetId, Map<String, String> cells) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefix + spreadsheetId, jsonEncode(cells));
  }

  Future<Map<String, String>> loadSheet(String spreadsheetId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefix + spreadsheetId);
    if (data == null) return {};
    try {
      final map = jsonDecode(data) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<void> clear(String spreadsheetId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefix + spreadsheetId);
  }
}
