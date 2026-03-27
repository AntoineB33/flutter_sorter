import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

class LoadedSheetsCache {
  final Map<int, CoreSheetContent> _loadedSheetsData = {};

  String getTitle(int sheetId) {
    return _loadedSheetsData[sheetId]!.title;
  }

  bool containsSheetId(int sheetId) {
    return _loadedSheetsData.containsKey(sheetId);
  }

  CoreSheetContent getSheet(int sheetId) {
    return _loadedSheetsData[sheetId]!;
  }

  Map<(int, int), String> getCells(int sheetId) {
    return _loadedSheetsData[sheetId]!.cells;
  }

  Map<int, ColumnType> getColumnTypes(int sheetId) {
    return _loadedSheetsData[sheetId]!.columnTypes;
  }

  int rowCount(int sheetId) {
    return getCells(sheetId).length;
  }

  int colCount(int sheetId) {
    return getCells(sheetId).table.isEmpty
        ? 0
        : getCells(sheetId).table[0].length;
  }

  String getCellContent(int sheetId, int row, int col) {
    final sheetContent = getCells(sheetId);
    if (row < sheetContent.table.length &&
        col < sheetContent.table[row].length) {
      return sheetContent.table[row][col];
    }
    return "";
  }

  ColumnType getColumnType(int sheetId, int col) {
    final sheetContent = getCells(sheetId);
    if (col < sheetContent.columnTypes.length) {
      return sheetContent.columnTypes[col];
    }
    return ColumnType.attributes;
  }

  String getSheetName(int sheetId) {
    return _loadedSheetsData[sheetId]?.title ?? '';
  }

  void setSheet(int sheetId, CoreSheetContent sheetData) {
    _loadedSheetsData[sheetId] = sheetData;
  }

  void _increaseColumnCount(
    int sheetId,
    int col,
    SheetContent sheetContent,
  ) {
    if (col >= colCount(sheetId)) {
      final needed = col + 1 - colCount(sheetId);
      for (var r = 0; r < rowCount(sheetId); r++) {
        sheetContent.table[r].addAll(List.filled(needed, '', growable: true));
      }
      sheetContent.columnTypes.addAll(
        List.filled(needed, ColumnType.attributes),
      );
    }
  }

  void _decreaseRowCount(int row, int rowCount, SheetContent sheetContent) {
    if (row == rowCount - 1) {
      while (row >= 0 &&
          !sheetContent.table[row].any((cell) => cell.isNotEmpty)) {
        sheetContent.table.removeLast();
        row--;
      }
    }
  }

  void _updateCell(int sheetId, CellUpdate update) {
    String prevValue = '';
    SheetContent sheetContent = _loadedSheetsData[sheetId]!.sheetContent;
    int row = update.rowId;
    int col = update.colId;
    String newValue = update.newValue;
    if (newValue.isNotEmpty ||
        (row < rowCount(sheetId) && col < colCount(sheetId))) {
      if (row >= rowCount(sheetId)) {
        final needed = row + 1 - rowCount(sheetId);
        sheetContent.table.addAll(
          List.generate(
            needed,
            (_) => List.filled(colCount(sheetId), '', growable: true),
          ),
        );
      }
      _increaseColumnCount(sheetId, col, sheetContent);
      prevValue = sheetContent.table[row][col];
      sheetContent.table[row][col] = newValue;
    }

    // Clean up empty rows/cols at the end
    if (newValue.isEmpty &&
        row < rowCount(sheetId) &&
        col < colCount(sheetId) &&
        (row == rowCount(sheetId) - 1 || col == colCount(sheetId) - 1) &&
        prevValue.isNotEmpty) {
      _decreaseRowCount(row, rowCount(sheetId), sheetContent);
      if (col == colCount(sheetId) - 1) {
        int colId = col;
        bool canRemove = true;
        while (canRemove && colId >= 0) {
          for (var r = 0; r < rowCount(sheetId); r++) {
            if (sheetContent.table[r][colId].isNotEmpty) {
              canRemove = false;
              break;
            }
          }
          if (canRemove) {
            for (var r = 0; r < rowCount(sheetId); r++) {
              sheetContent.table[r].removeLast();
            }
            colId--;
          }
        }
      }
    }
  }

  void update(List<UpdateUnit> updates, int sheetId) {
    for (var update in updates) {
      if (update is CellUpdate) {
        _updateCell(sheetId, update);
      } else if (update is ColumnTypeUpdate) {
        _setColumnType(sheetId, update);
      } else {
        throw Exception('Unsupported update type: ${update.runtimeType}');
      }
    }
  }

  void _setColumnType(int sheetId, ColumnTypeUpdate update) {
    int col = update.colId;
    ColumnType type = update.newColumnType;
    final sheet = _loadedSheetsData[sheetId]!;
    if (type == ColumnType.attributes) {
      if (col < colCount(sheetId)) {
        sheet.columnTypes[col] = type;
        if (col == sheet.columnTypes.length - 1) {
          while (col > 0) {
            col--;
            if (sheet.columnTypes[col] != ColumnType.attributes) {
              break;
            }
          }
          sheet.columnTypes = sheet.columnTypes.sublist(
            0,
            col + 1,
          );
        }
      }
    } else {
      _increaseColumnCount(sheetId, col, sheet);
      sheet.columnTypes[col] = type;
    }
  }
}
