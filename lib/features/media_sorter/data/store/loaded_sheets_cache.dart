import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/utils/logger.dart';

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

  Map<CellPosition, String> getCells(int sheetId) {
    return _loadedSheetsData[sheetId]!.cells;
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

  void update(Map<String, UpdateUnit> updates, int sheetId) {
    for (var update in updates.values) {
      switch (update) {
        case CellUpdate():
          _updateCell(sheetId, update);
          break;
        case ColumnTypeUpdate():
          _setColumnType(sheetId, update);
          break;
        case SheetDataUpdate():
          if (update.newName != null) {
            _loadedSheetsData[sheetId]!.title = update.newName!;
          }
          break;
        default:
          throw Exception('Unknown update type');
      }
    }
  }

  void _setColumnType(int sheetId, ColumnTypeUpdate update) {
    int col = update.colId;
    ColumnType type = update.newColumnType;
    final sheet = _loadedSheetsData[sheetId]!;
    if (type == ColumnType.attributes ) {
      sheet.columnTypes.remove(col);
    } else {
      sheet.columnTypes[col] = type;
    }
  }
}
