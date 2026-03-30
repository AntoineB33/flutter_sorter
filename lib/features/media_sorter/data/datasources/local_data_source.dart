import 'package:drift/native.dart';
import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:drift/drift.dart';

abstract class ILocalDataSource {
  Future<void> batchInsertOrUpdate(List<UpdateUnit> items);
  Future<SheetDataTable> getSheet(int sheetId);
  Future<List<SheetCell>> getCells(int sheetId);
  Future<List<SheetColumnType>> getColumnTypes(int sheetId);
  Future<List<SheetDataTable>> getSortStatus();
}



class DriftLocalDataSource implements ILocalDataSource {
  final AppDatabase db;

  DriftLocalDataSource(this.db);

  @override
  Future<void> batchInsertOrUpdate(List<UpdateUnit> items) async {
  await db.batch((batch) {
    for (final item in items) {
      switch (item) {
        case SheetDataUpdate():
          final companion = SheetDataTablesCompanion(
            id: Value(item.sheetId),
            title: item.newName != null ? Value(item.newName!) : Value.absent(),
            historyIndex: item.historyIndex != null ? Value(item.historyIndex!) : Value.absent(),
            colHeaderHeight: item.colHeaderHeight != null ? Value(item.colHeaderHeight!) : Value.absent(),
            rowHeaderWidth: item.rowHeaderWidth != null ? Value(item.rowHeaderWidth!) : Value.absent(),
            primarySelectedCellX: item.primarySelectedCellX != null ? Value(item.primarySelectedCellX!) : Value.absent(),
            primarySelectedCellY: item.primarySelectedCellY != null ? Value(item.primarySelectedCellY!) : Value.absent(),
            scrollOffsetX: item.scrollOffsetX != null ? Value(item.scrollOffsetX!) : Value.absent(),
            scrollOffsetY: item.scrollOffsetY != null ? Value(item.scrollOffsetY!) : Value.absent(),
            bestSortFound: item.bestSortFound != null ? Value(item.bestSortFound!) : Value.absent(),
            bestDistFound: item.bestDistFound != null ? Value(item.bestDistFound!) : Value.absent(),
            cursors: item.cursors != null ? Value(item.cursors!) : Value.absent(),
            possibleInts: item.possibleInts != null ? Value(item.possibleInts!) : Value.absent(),
            validAreas: item.validAreas != null ? Value(item.validAreas!) : Value.absent(),
            sortIndex: item.sortIndex != null ? Value(item.sortIndex!) : Value.absent(),
            analysisResult : item.analysisResult != null ? Value(item.analysisResult!) : Value.absent(),
            sortInProgress: item.sortInProgress != null ? Value(item.sortInProgress!) : Value.absent(),
            toApplyNextBestSort: item.toApplyNextBestSort != null ? Value(item.toApplyNextBestSort!) : Value.absent(),
            toAlwaysApplyCurrentBestSort: item.toAlwaysApplyCurrentBestSort != null ? Value(item.toAlwaysApplyCurrentBestSort!) : Value.absent(),
            analysisDone: item.analysisDone != null ? Value(item.analysisDone!) : Value.absent(),
          );
          if (item.addOtherwiseRemove) {
            batch.insert(
              db.sheetDataTables,
              companion, 
              mode: InsertMode.insertOrReplace,
            );
          } else {
            batch.delete(db.sheetDataTables, companion);
          }
          break;
        case CellUpdate():
          // Create a companion object mapped to your SheetCells table
          final companion = SheetCellsCompanion(
            sheetId: Value(item.sheetId),
            row: Value(item.rowId),
            col: Value(item.colId),
            content: Value(item.newValue),
          );
          if (item.newValue.isNotEmpty) {
            batch.insert(
              db.sheetCells,
              companion, 
              mode: InsertMode.insertOrReplace,
            );
          } else {
            batch.delete(db.sheetCells, companion);
          }
          break;
        case ColumnTypeUpdate():
          final companion = SheetColumnTypesCompanion(
            sheetId: Value(item.sheetId),
            columnIndex: Value(item.colId),
            columnType: Value(item.newColumnType.toString()),
          );
          if (item.newColumnType != ColumnType.attributes) {
            batch.insert(
              db.sheetColumnTypes,
              companion, 
              mode: InsertMode.insertOrReplace,
            );
          } else {
            batch.delete(db.sheetColumnTypes, companion);
          }
          break;
        case UpdateData():
          UpdateData updateData = item;
          if (updateData.addOtherwiseRemove) {
            batch.insert(
              db.updateHistories,
              UpdateHistoriesCompanion(
                timestamp: Value(updateData.timestamp),
                chronoId: Value(updateData.chronoId),
                updates: Value(updateData.updates),
              ),
              mode: InsertMode.insertOrReplace,
            );
          } else {
            batch.delete(db.updateHistories, UpdateHistoriesCompanion(
              timestamp: Value(updateData.timestamp),
              chronoId: Value(updateData.chronoId),
            ));
          }
          break;
        case RowsBottomPosUpdate():
          final companion = RowsBottomPosCompanion(
            sheetId: Value(item.sheetId),
            rowIndex: Value(item.rowIndex),
            bottomPos: Value(item.newBottomPos),
          );
          if (item.addOtherwiseRemove) {
            batch.insert(
              db.rowsBottomPos,
              companion, 
              mode: InsertMode.insertOrReplace,
            );
          } else {
            batch.delete(db.rowsBottomPos, companion);
          }
          break;
        case ColRightPosUpdate():
          final companion = ColRightPosCompanion(
            sheetId: Value(item.sheetId),
            colIndex: Value(item.colIndex),
            rightPos: Value(item.newRightPos),
          );
          if (item.addOtherwiseRemove) {
            batch.insert(
              db.colRightPos,
              companion, 
              mode: InsertMode.insertOrReplace,
            );
          } else {
            batch.delete(db.colRightPos, companion);
          }
          break;
        case RowsManuallyAdjustedHeightUpdate():
          final companion = RowsManuallyAdjustedHeightCompanion(
            sheetId: Value(item.sheetId),
            rowIndex: Value(item.rowIndex),
            manuallyAdjusted: Value(item.manuallyAdjusted),
          );
          if (item.addOtherwiseRemove) {
            batch.insert(
              db.rowsManuallyAdjustedHeight,
              companion, 
              mode: InsertMode.insertOrReplace,
            );
          } else {
            batch.delete(db.rowsManuallyAdjustedHeight, companion);
          }
          break;
        case ColsManuallyAdjustedWidthUpdate():
          final companion = ColsManuallyAdjustedWidthCompanion(
            sheetId: Value(item.sheetId),
            colIndex: Value(item.colIndex),
            manuallyAdjusted: Value(item.manuallyAdjusted),
          );
          if (item.addOtherwiseRemove) {
            batch.insert(
              db.colsManuallyAdjustedWidth,
              companion, 
              mode: InsertMode.insertOrReplace,
            );
          } else {
            batch.delete(db.colsManuallyAdjustedWidth, companion);
          }
          break;
      }
    }  });
  }

  @override
  Future<SheetDataTable> getSheet(int sheetId) async {
    try {
      final query = db.select(db.sheetDataTables)..where((table) => table.id.equals(sheetId));
      final coreSheetContents = await query.getSingleOrNull();
      if (coreSheetContents == null) {
        throw CacheException("Sheet with id $sheetId not found");
      }
      return coreSheetContents;
    } on SqliteException catch (e) {
      throw CacheException('Failed to insert user: ${e.message}');
    } catch (e) {
      throw CacheException('An unknown database error occurred.');
    }
  }

  @override
  Future<List<SheetCell>> getCells(int sheetId) async {
    try {
      final query = db.select(db.sheetCells)..where((table) => table.sheetId.equals(sheetId));
      final cells = await query.get();
      return cells;
    } on SqliteException catch (e) {
      throw CacheException('Failed to retrieve cells: ${e.message}');
    } catch (e) {
      throw CacheException('An unknown database error occurred.');
    }
  }

  @override
  Future<List<SheetColumnType>> getColumnTypes(int sheetId) async {
    try {
      final query = db.select(db.sheetColumnTypes)..where((table) => table.sheetId.equals(sheetId));
      final columnTypes = await query.get();
      return columnTypes;
    } on SqliteException catch (e) {
      throw CacheException('Failed to retrieve column types: ${e.message}');
    } catch (e) {
      throw CacheException('An unknown database error occurred.');
    }
  }

  @override
  Future<List<SheetDataTable>> getSortStatus() async {
    try {
      final query = db.select(db.sheetDataTables);
      final rows = await query.get();
      return rows;
    } on SqliteException catch (e) {
      throw CacheException('Failed to retrieve sort status: ${e.message}');
    } catch (e) {
      throw CacheException('An unknown database error occurred.');
    }

  }
}