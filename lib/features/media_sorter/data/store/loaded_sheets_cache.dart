import 'dart:async';

import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';

class LoadedSheetsCache {
  final Map<String, SheetData> _loadedSheetsData = {};
  final List<String> _recentSheetIds = [];
  final _saveController = StreamController<void>.broadcast();

  Stream<void> get saveStream => _saveController.stream;
  List<String> get recentSheetIds => List.unmodifiable(_recentSheetIds);
  String get currentSheetId => _recentSheetIds.first;
  SheetData get currentSheet => _loadedSheetsData[currentSheetId]!;

  set recentSheetIds(List<String> names) {
    _recentSheetIds.clear();
    _recentSheetIds.addAll(names);
  }

  bool containsSheetId(String sheetId) {
    return _loadedSheetsData.containsKey(sheetId);
  }

  SheetData getSheet(String sheetId) {
    return _loadedSheetsData[sheetId]!;
  }

  SheetContent getSheetContent(String sheetId) {
    return _loadedSheetsData[sheetId]!.sheetContent;
  }

  int rowCount(String sheetId) {
    return getSheetContent(sheetId).table.length;
  }

  int colCount(String sheetId) {
    return getSheetContent(sheetId).table.isEmpty
        ? 0
        : getSheetContent(sheetId).table[0].length;
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

  void addSheetId(String sheetId) {
    _recentSheetIds.insert(1, sheetId);
    _saveController.add(null);
  }

  void removeSheet(int index) {
    _recentSheetIds.removeAt(index);
    _saveController.add(null);
  }
}
