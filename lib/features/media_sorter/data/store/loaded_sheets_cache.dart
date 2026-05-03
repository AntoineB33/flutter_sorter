import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
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

  List<SyncRequestWithoutHist> updateCell(
    int sheetId,
    SheetCellsTableCompanion update,
    DataBaseOperationType operationType,
  ) {
    _loadedSheetsData[sheetId]!.cells[CellPosition(
          update.row.value,
          update.col.value,
        )] =
        update.content.value;
    final usedRows = _loadedSheetsData[sheetId]!.usedRows;
    final usedCols = _loadedSheetsData[sheetId]!.usedCols;
    List<int>? newUsedRows;
    List<int>? newUsedCols;
    if (operationType != DataBaseOperationType.delete) {
      if (!usedRows.contains(update.row.value)) {
        usedRows.insert(
          lowerBound(usedRows, update.row.value),
          update.row.value,
        );
        newUsedRows = usedRows;
      }
      if (!usedCols.contains(update.col.value)) {
        usedCols.insert(
          lowerBound(usedCols, update.col.value),
          update.col.value,
        );
        newUsedCols = usedCols;
      }
    } else {
      bool isRowUsed = false;
      for (int row in usedRows) {
        if (getCellContent(sheetId, row, update.col.value).isNotEmpty) {
          isRowUsed = true;
          break;
        }
      }
      if (!isRowUsed) {
        usedCols.remove(update.col.value);
        newUsedCols = usedCols;
      }
      bool isColUsed = false;
      for (int col in usedCols) {
        if (getCellContent(sheetId, update.row.value, col).isNotEmpty) {
          isColUsed = true;
          break;
        }
      }
      if (!isColUsed) {
        usedRows.remove(update.row.value);
        newUsedRows = usedRows;
      }
    }
    List<SyncRequestWithoutHist> changeList = [];
    if (newUsedRows != null || newUsedCols != null) {
      changeList.add(
        SyncRequestWithoutHist(
          SheetDataWrapper(
            SheetDataTablesCompanion(
              sheetId: Value(sheetId),
              usedRows: newUsedRows != null
                  ? Value(newUsedRows)
                  : Value.absent(),
              usedCols: newUsedCols != null
                  ? Value(newUsedCols)
                  : Value.absent(),
            ),
          ),
          SheetDataWrapper(
            SheetDataTablesCompanion(
              sheetId: Value(sheetId),
              usedRows: newUsedRows != null
                  ? Value(getSheet(sheetId).usedRows)
                  : Value.absent(),
              usedCols: newUsedCols != null
                  ? Value(getSheet(sheetId).usedCols)
                  : Value.absent(),
            ),
          ),
          DataBaseOperationType.update,
        ),
      );
    }
    return changeList;
  }

  void setColumnType(int sheetId, int col, ColumnType newColumnType) {
    final sheet = _loadedSheetsData[sheetId]!;
    if (newColumnType == ColumnType.attributes) {
      sheet.columnTypes.remove(col);
    } else {
      sheet.columnTypes[col] = newColumnType;
    }
  }
}
