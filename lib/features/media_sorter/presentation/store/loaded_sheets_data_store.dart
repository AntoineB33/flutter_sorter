import 'dart:async';

import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';

class LoadedSheetsDataStore {
  final Map<String, SheetData> _loadedSheetsData = {};
  final List<String> _recentSheetIds = [];

  List<String> get recentSheetIds => List.unmodifiable(_recentSheetIds);
  String get currentSheetId => _recentSheetIds.first;
  SheetData get currentSheet => _loadedSheetsData[currentSheetId]!;

  set recentSheetIds(List<String> names) {
    _recentSheetIds.clear();
    _recentSheetIds.addAll(names);
  }

  SheetData getSheet(String sheetId) {
    return _loadedSheetsData[sheetId]!;
  }

  String getCellContent(int row, int col) {
    if (row < currentSheet.sheetContent.table.length &&
        col < currentSheet.sheetContent.table[row].length) {
      return currentSheet.sheetContent.table[row][col];
    }
    return "";
  }

  ColumnType getColumnType(int col) {
    if (col < currentSheet.sheetContent.columnTypes.length) {
      return currentSheet.sheetContent.columnTypes[col];
    }
    return ColumnType.attributes;
  }

  void dispose() {
    _updateController.close();
  }
}
