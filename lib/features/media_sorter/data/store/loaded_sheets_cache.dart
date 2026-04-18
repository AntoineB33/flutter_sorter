import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/features/media_sorter/data/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/update_data.dart';

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
    return getSheet(sheetId).usedRows.isEmpty
        ? 0
        : getSheet(sheetId).usedRows.last + 1;
  }

  int colCount(int sheetId) {
    return getSheet(sheetId).usedCols.isEmpty
        ? 0
        : getSheet(sheetId).usedCols.last + 1;
  }

  String getCellContent(int sheetId, int row, int col) {
    return getCells(sheetId)[CellPosition(row, col)] ?? '';
  }

  ColumnType getColumnType(int sheetId, int col) {
    return _loadedSheetsData[sheetId]!.columnTypes[col] ??
        ColumnType.attributes;
  }

  void setSheet(int sheetId, CoreSheetContent sheetData) {
    _loadedSheetsData[sheetId] = sheetData;
  }

  @useResult
  ChangeSet _updateCell(int sheetId, CellUpdate update) {
    final changeSet = ChangeSet();
    _loadedSheetsData[sheetId]!.cells[CellPosition(
          update.rowId,
          update.colId,
        )] =
        update.newValue;
    final usedRows = _loadedSheetsData[sheetId]!.usedRows;
    final usedCols = _loadedSheetsData[sheetId]!.usedCols;
    List<int>? newUsedRows;
    List<int>? newUsedCols;
    if (update.newValue.isNotEmpty) {
      if (!usedRows.contains(update.rowId)) {
        usedRows.insert(lowerBound(usedRows, update.rowId), update.rowId);
        newUsedRows = usedRows;
      }
      if (!usedCols.contains(update.colId)) {
        usedCols.insert(lowerBound(usedCols, update.colId), update.colId);
        newUsedCols = usedCols;
      }
    } else {
      bool isRowUsed = false;
      for (int row in usedRows) {
        if (getCellContent(sheetId, row, update.colId).isNotEmpty) {
          isRowUsed = true;
          break;
        }
      }
      if (!isRowUsed) {
        usedCols.remove(update.colId);
        newUsedCols = usedCols;
      }
      bool isColUsed = false;
      for (int col in usedCols) {
        if (getCellContent(sheetId, update.rowId, col).isNotEmpty) {
          isColUsed = true;
          break;
        }
      }
      if (!isColUsed) {
        usedRows.remove(update.rowId);
        newUsedRows = usedRows;
      }
    }
    if (newUsedRows != null || newUsedCols != null) {
      changeSet.addUpdate(
        SheetDataUpdate(
          sheetId,
          true,
          usedRows: newUsedRows,
          usedCols: newUsedCols,
        ),
      );
    }
    return changeSet;
  }

  @useResult
  ChangeSet update(IMap<String, SyncRequest> updates, int sheetId) {
    final changeSet = ChangeSet();
    for (var update in updates.values) {
      switch (update) {
        case CellUpdate():
          changeSet.merge(_updateCell(sheetId, update));
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
    return changeSet;
  }

  void _setColumnType(int sheetId, ColumnTypeUpdate update) {
    int col = update.colId;
    ColumnType type = update.newColumnType;
    final sheet = _loadedSheetsData[sheetId]!;
    if (type == ColumnType.attributes) {
      sheet.columnTypes.remove(col);
    } else {
      sheet.columnTypes[col] = type;
    }
  }
}
