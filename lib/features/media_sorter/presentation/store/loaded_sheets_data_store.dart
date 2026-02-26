import 'dart:async';

import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';

class LoadedSheetsDataStore {
  final Map<String, SheetData> _loadedSheetsData = {};
  final List<String> _recentSheetIds = [];

  final _updateController = StreamController<String>.broadcast();

  Stream<String> get onSheetUpdated => _updateController.stream;
  List<String> get recentSheetIds => List.unmodifiable(_recentSheetIds);
  String get currentSheetId => _recentSheetIds.first;
  SheetData get currentSheet => _loadedSheetsData[currentSheetId]!;

  set recentSheetIds(List<String> names) {
    _recentSheetIds.clear();
    _recentSheetIds.addAll(names);
  }

  SheetData getSheet(String sheetName) {
    return _loadedSheetsData[sheetName]!;
  }

  String getCellContent(String sheetName, int row, int col) {
    final sheet = getSheet(sheetName);
    if (row < sheet.sheetContent.table.length &&
        col < sheet.sheetContent.table[row].length) {
      return sheet.sheetContent.table[row][col];
    }
    return "";
  }

  void dispose() {
    _updateController.close();
  }
}
