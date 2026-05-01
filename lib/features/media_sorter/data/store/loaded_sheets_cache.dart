import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/core_sheet_content.dart';

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

  List<SyncRequestWithoutHistImpl> _updateCell(
    int sheetId,
    SheetCellsTableCompanion update,
  ) {
    List<SyncRequestWithoutHistImpl> changeList = [];
    _loadedSheetsData[sheetId]!.cells[CellPosition(
          update.row.value,
          update.col.value,
        )] =
        update.content.value;
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
      changeList.addUpdate(
        SheetDataUpdate(
          sheetId,
          true,
          usedRows: newUsedRows,
          usedCols: newUsedCols,
        ),
      );
    }
    return changeList;
  }

  changeList renameSheet(int sheetId, String newName) {
    _loadedSheetsData[sheetId]!.title = newName;
    return changeListImpl()
      ..addUpdate(SheetDataUpdate(sheetId, true, title: newName));
  }

  void setColumnType(int sheetId, ColumnTypeUpdate update) {
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
