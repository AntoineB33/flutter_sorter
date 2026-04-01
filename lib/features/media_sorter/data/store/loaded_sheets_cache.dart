import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
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
    return getSheet(sheetId).lastRow + 1;
  }

  int colCount(int sheetId) {
    return getSheet(sheetId).lastCol + 1;
  }

  String getCellContent(int sheetId, int row, int col) {
    return getCells(sheetId)[CellPosition(row, col)] ?? '';
  }

  ColumnType getColumnType(int sheetId, int col) {
    return _loadedSheetsData[sheetId]!.columnTypes[col] ?? ColumnType.attributes;
  }

  String getSheetName(int sheetId) {
    return _loadedSheetsData[sheetId]?.title ?? '';
  }

  void setSheet(int sheetId, CoreSheetContent sheetData) {
    _loadedSheetsData[sheetId] = sheetData;
  }

  void _updateCell(int sheetId, CellUpdate update) {
    _loadedSheetsData[sheetId]!.cells[CellPosition(update.rowId, update.colId)] =
        update.newValue;
    if (update.rowId > _loadedSheetsData[sheetId]!.lastRow) {
      _loadedSheetsData[sheetId]!.lastRow = update.rowId;
    } else if (update.rowId == _loadedSheetsData[sheetId]!.lastRow &&
        update.newValue.isEmpty) {
      while (_loadedSheetsData[sheetId]!.lastRow >= 0) {
        for (int col = 0; col <= _loadedSheetsData[sheetId]!.lastCol; col++) {
          if (getCellContent(sheetId, _loadedSheetsData[sheetId]!.lastRow, col)
              .isNotEmpty) {
            return;
          }
        }
        _loadedSheetsData[sheetId]!.lastRow--;
      }
    }
    if (update.colId > _loadedSheetsData[sheetId]!.lastCol) {
      _loadedSheetsData[sheetId]!.lastCol = update.colId;
    } else if (update.colId == _loadedSheetsData[sheetId]!.lastCol &&
        update.newValue.isEmpty) {
      while (_loadedSheetsData[sheetId]!.lastCol >= 0) {
        for (int row = 0; row <= _loadedSheetsData[sheetId]!.lastRow; row++) {
          if (getCellContent(sheetId, row, _loadedSheetsData[sheetId]!.lastCol)
              .isNotEmpty) {
            return;
          }
        }
        _loadedSheetsData[sheetId]!.lastCol--;
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
          break;
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
