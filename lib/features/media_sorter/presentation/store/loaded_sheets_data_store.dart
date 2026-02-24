import 'dart:async';

import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_data.dart';



class LoadedSheetsDataStore {
  final Map<String, SheetData> _loadedSheetsData = {};
  final List<String> _sheetNames = [];
  final String _currentSheetName = "";

  final _updateController = StreamController<String>.broadcast();
  
  Stream<String> get onSheetUpdated => _updateController.stream;
  List<String> get sheetNames => _sheetNames;
  String get currentSheetName => _currentSheetName;
  SheetData get currentSheet => _loadedSheetsData[_currentSheetName]!;

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

  void setCellsContent(String sheetName, List<CellUpdate> updates) {
    final sheet = getSheet(sheetName);
    for (var update in updates) {
      sheet.sheetContent.table[update.row][update.col] = update.value;
    }
    _updateController.add(sheetName);
  }
  
  void dispose() {
    _updateController.close();
  }
}