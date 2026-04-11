import 'package:drift/native.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/data/models/column_type.dart';
import 'package:trying_flutter/features/media_sorter/data/models/update_data.dart';
import 'package:drift/drift.dart';

class SheetIdAndLastOpened {
  final int sheetId;
  final DateTime lastOpened;

  SheetIdAndLastOpened(this.sheetId, this.lastOpened);
}

abstract class ILocalDataSource {
  Future<void> batchInsertOrUpdate(List<UpdateUnit> items);
  Future<List<SheetIdAndLastOpened>> getSheetIdAndLastOpened();
  Future<SheetDataEntity> getSheetDataEntity(int sheetId);
  Future<List<SheetCellEntity>> getSheetCellEntities(int sheetId);
  Future<List<SheetColumnTypeEntity>> getSheetColumnTypeEntities(int sheetId);
  Future<List<UpdateHistoriesEntity>> getUpdateHistoriesEntities(int sheetId);
  Future<List<RowsBottomPosEntity>> getRowsBottomPosEntities(int sheetId);
  Future<List<ColRightPosEntity>> getColRightPosEntities(int sheetId);
  Future<List<RowsManuallyAdjustedHeightEntity>>
  getRowsManuallyAdjustedHeightEntities(int sheetId);
  Future<List<ColsManuallyAdjustedWidthEntity>>
  getColsManuallyAdjustedWidthEntities(int sheetId);
  Future<List<SortStatusData>> getSortStatus();
  Future<void> clearAllData();
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
              title: item.newName != null
                  ? Value(item.newName!)
                  : Value.absent(),
              historyIndex: item.historyIndex != null
                  ? Value(item.historyIndex!)
                  : Value.absent(),
              colHeaderHeight: item.colHeaderHeight != null
                  ? Value(item.colHeaderHeight!)
                  : Value.absent(),
              rowHeaderWidth: item.rowHeaderWidth != null
                  ? Value(item.rowHeaderWidth!)
                  : Value.absent(),
              selectionHistory: item.selectionHistory != null
                  ? Value(item.selectionHistory!)
                  : Value.absent(),
              scrollOffsetX: item.scrollOffsetX != null
                  ? Value(item.scrollOffsetX!)
                  : Value.absent(),
              scrollOffsetY: item.scrollOffsetY != null
                  ? Value(item.scrollOffsetY!)
                  : Value.absent(),
              bestSortFound: item.bestSortFound != null
                  ? Value(item.bestSortFound!)
                  : Value.absent(),
              bestDistFound: item.bestDistFound != null
                  ? Value(item.bestDistFound!)
                  : Value.absent(),
              cursors: item.cursors != null
                  ? Value(item.cursors!)
                  : Value.absent(),
              possibleInts: item.possibleInts != null
                  ? Value(item.possibleInts!)
                  : Value.absent(),
              validAreas: item.validAreas != null
                  ? Value(item.validAreas!)
                  : Value.absent(),
              sortIndex: item.sortIndex != null
                  ? Value(item.sortIndex!)
                  : Value.absent(),
              analysisResult: item.analysisResult != null
                  ? Value(item.analysisResult!)
                  : Value.absent(),
              sortInProgress: item.sortInProgress != null
                  ? Value(item.sortInProgress!)
                  : Value.absent(),
              toApplyNextBestSort: item.toApplyNextBestSort != null
                  ? Value(item.toApplyNextBestSort!)
                  : Value.absent(),
              toAlwaysApplyCurrentBestSort:
                  item.toAlwaysApplyCurrentBestSort != null
                  ? Value(item.toAlwaysApplyCurrentBestSort!)
                  : Value.absent(),
              analysisDone: item.analysisDone != null
                  ? Value(item.analysisDone!)
                  : Value.absent(),
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
            final companion = SheetCellsTableCompanion(
              sheetId: Value(item.sheetId),
              row: Value(item.rowId),
              col: Value(item.colId),
              content: Value(item.newValue),
            );
            if (item.newValue.isNotEmpty) {
              batch.insert(
                db.sheetCellsTable,
                companion,
                mode: InsertMode.insertOrReplace,
              );
            } else {
              batch.delete(db.sheetCellsTable, companion);
            }
            break;
          case ColumnTypeUpdate():
            final companion = SheetColumnTypesTableCompanion(
              sheetId: Value(item.sheetId),
              columnIndex: Value(item.colId),
              columnType: Value(item.newColumnType),
            );
            if (item.newColumnType != ColumnType.attributes) {
              batch.insert(
                db.sheetColumnTypesTable,
                companion,
                mode: InsertMode.insertOrReplace,
              );
            } else {
              batch.delete(db.sheetColumnTypesTable, companion);
            }
            break;
          case UpdateData():
            UpdateData updateData = item;
            if (updateData.addOtherwiseRemove) {
              batch.insert(
                db.updateHistoriesTable,
                UpdateHistoriesTableCompanion(
                  timestamp: Value(updateData.timestamp),
                  chronoId: Value(updateData.chronoId),
                  updates: Value(updateData.updates),
                ),
                mode: InsertMode.insertOrReplace,
              );
            } else {
              batch.delete(
                db.updateHistoriesTable,
                UpdateHistoriesTableCompanion(
                  timestamp: Value(updateData.timestamp),
                  chronoId: Value(updateData.chronoId),
                ),
              );
            }
            break;
          case RowsBottomPosUpdate():
            final companion = RowsBottomPosTableCompanion(
              sheetId: Value(item.sheetId),
              rowIndex: Value(item.rowIndex),
              bottomPos: item.newBottomPos != null
                  ? Value(item.newBottomPos!)
                  : Value.absent(),
            );
            if (item.newBottomPos != null) {
              batch.insert(
                db.rowsBottomPosTable,
                companion,
                mode: InsertMode.insertOrReplace,
              );
            } else {
              batch.delete(db.rowsBottomPosTable, companion);
            }
            break;
          case ColRightPosUpdate():
            final companion = ColRightPosTableCompanion(
              sheetId: Value(item.sheetId),
              colIndex: Value(item.colIndex),
              rightPos: Value(item.newRightPos),
            );
            if (item.addOtherwiseRemove) {
              batch.insert(
                db.colRightPosTable,
                companion,
                mode: InsertMode.insertOrReplace,
              );
            } else {
              batch.delete(db.colRightPosTable, companion);
            }
            break;
          case RowsManuallyAdjustedHeightUpdate():
            final companion = RowsManuallyAdjustedHeightTableCompanion(
              sheetId: Value(item.sheetId),
              rowIndex: Value(item.rowIndex),
              manuallyAdjusted: Value(item.manuallyAdjusted),
            );
            if (item.addOtherwiseRemove) {
              batch.insert(
                db.rowsManuallyAdjustedHeightTable,
                companion,
                mode: InsertMode.insertOrReplace,
              );
            } else {
              batch.delete(db.rowsManuallyAdjustedHeightTable, companion);
            }
            break;
          case ColsManuallyAdjustedWidthUpdate():
            final companion = ColsManuallyAdjustedWidthTableCompanion(
              sheetId: Value(item.sheetId),
              colIndex: Value(item.colIndex),
              manuallyAdjusted: Value(item.manuallyAdjusted),
            );
            if (item.addOtherwiseRemove) {
              batch.insert(
                db.colsManuallyAdjustedWidthTable,
                companion,
                mode: InsertMode.insertOrReplace,
              );
            } else {
              batch.delete(db.colsManuallyAdjustedWidthTable, companion);
            }
            break;
        }
      }
    });
  }

  @override
  Future<List<SheetIdAndLastOpened>> getSheetIdAndLastOpened() async {
    try {
      final query = db.selectOnly(db.sheetDataTables)
        ..addColumns([db.sheetDataTables.id, db.sheetDataTables.lastOpened]);
      final result = await query.get();
      return result
          .map(
            (row) => SheetIdAndLastOpened(
              row.read(db.sheetDataTables.id)!,
              row.read(db.sheetDataTables.lastOpened)!,
            ),
          )
          .toList();
    } on SqliteException catch (e) {
      throw CacheException(
        'Failed to retrieve sheet ID and last opened: ${e.message}',
      );
    } catch (e) {
      throw CacheException('An unknown database error occurred.');
    }
  }

  @override
  Future<SheetDataEntity> getSheetDataEntity(int sheetId) async {
    try {
      final query = db.select(db.sheetDataTables)
        ..where((table) => table.id.equals(sheetId));
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
  Future<List<SheetCellEntity>> getSheetCellEntities(int sheetId) async {
    try {
      final query = db.select(db.sheetCellsTable)
        ..where((table) => table.sheetId.equals(sheetId));
      final cells = await query.get();
      return cells;
    } on SqliteException catch (e) {
      throw CacheException('Failed to retrieve cells: ${e.message}');
    } catch (e) {
      throw CacheException('An unknown database error occurred.');
    }
  }

  @override
  Future<List<SheetColumnTypeEntity>> getSheetColumnTypeEntities(
    int sheetId,
  ) async {
    try {
      final query = db.select(db.sheetColumnTypesTable)
        ..where((table) => table.sheetId.equals(sheetId));
      final columnTypes = await query.get();
      return columnTypes;
    } on SqliteException catch (e) {
      throw CacheException('Failed to retrieve column types: ${e.message}');
    } catch (e) {
      throw CacheException('An unknown database error occurred.');
    }
  }

  @override
  Future<List<UpdateHistoriesEntity>> getUpdateHistoriesEntities(
    int sheetId,
  ) async {
    try {
      final query = db.select(db.updateHistoriesTable)
        ..where((table) => table.sheetId.equals(sheetId))
        ..orderBy([
          (t) => OrderingTerm.asc(t.timestamp),
          (t) => OrderingTerm.asc(t.chronoId),
        ]);
      final updateHistories = await query.get();
      return updateHistories;
    } on SqliteException catch (e) {
      throw CacheException('Failed to retrieve update histories: ${e.message}');
    } catch (e) {
      throw CacheException('An unknown database error occurred.');
    }
  }

  @override
  Future<List<RowsBottomPosEntity>> getRowsBottomPosEntities(
    int sheetId,
  ) async {
    try {
      final query = db.select(db.rowsBottomPosTable)
        ..where((table) => table.sheetId.equals(sheetId));
      final rowsBottomPos = await query.get();
      return rowsBottomPos;
    } on SqliteException catch (e) {
      throw CacheException(
        'Failed to retrieve rows bottom positions: ${e.message}',
      );
    } catch (e) {
      throw CacheException('An unknown database error occurred.');
    }
  }

  @override
  Future<List<ColRightPosEntity>> getColRightPosEntities(int sheetId) async {
    try {
      final query = db.select(db.colRightPosTable)
        ..where((table) => table.sheetId.equals(sheetId));
      final colRightPos = await query.get();
      return colRightPos;
    } on SqliteException catch (e) {
      throw CacheException(
        'Failed to retrieve column right positions: ${e.message}',
      );
    } catch (e) {
      throw CacheException('An unknown database error occurred.');
    }
  }

  @override
  Future<List<RowsManuallyAdjustedHeightEntity>>
  getRowsManuallyAdjustedHeightEntities(int sheetId) async {
    try {
      final query = db.select(db.rowsManuallyAdjustedHeightTable)
        ..where((table) => table.sheetId.equals(sheetId));
      final rowsManuallyAdjustedHeight = await query.get();
      return rowsManuallyAdjustedHeight;
    } on SqliteException catch (e) {
      throw CacheException(
        'Failed to retrieve rows manually adjusted heights: ${e.message}',
      );
    } catch (e) {
      throw CacheException('An unknown database error occurred.');
    }
  }

  @override
  Future<List<ColsManuallyAdjustedWidthEntity>>
  getColsManuallyAdjustedWidthEntities(int sheetId) async {
    try {
      final query = db.select(db.colsManuallyAdjustedWidthTable)
        ..where((table) => table.sheetId.equals(sheetId));
      final colsManuallyAdjustedWidth = await query.get();
      return colsManuallyAdjustedWidth;
    } on SqliteException catch (e) {
      throw CacheException(
        'Failed to retrieve columns manually adjusted widths: ${e.message}',
      );
    } catch (e) {
      throw CacheException('An unknown database error occurred.');
    }
  }

  @override
  Future<List<SortStatusData>> getSortStatus() async {
    try {
      final query = db.selectOnly(db.sheetDataTables)
        ..addColumns([
          db.sheetDataTables.id,
          db.sheetDataTables.sortInProgress,
          db.sheetDataTables.toApplyNextBestSort,
          db.sheetDataTables.toAlwaysApplyCurrentBestSort,
          db.sheetDataTables.analysisDone,
        ])
        ..where(db.sheetDataTables.sortInProgress.equals(true));
      final result = await query.get();
      return result
          .map(
            (row) => SortStatusData(
              sheetId: row.read(db.sheetDataTables.id)!,
              toApplyNextBestSort:
                  row.read(db.sheetDataTables.toApplyNextBestSort) ?? false,
              analysisDone: row.read(db.sheetDataTables.analysisDone) ?? false,
            ),
          )
          .toList();
    } on SqliteException catch (e) {
      throw CacheException('Failed to retrieve sort status: ${e.message}');
    } catch (e) {
      throw CacheException('An unknown database error occurred.');
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await db.transaction(() async {
        await db.delete(db.sheetDataTables).go();
        await db.delete(db.sheetCellsTable).go();
        await db.delete(db.sheetColumnTypesTable).go();
        await db.delete(db.updateHistoriesTable).go();
        await db.delete(db.rowsBottomPosTable).go();
        await db.delete(db.colRightPosTable).go();
        await db.delete(db.rowsManuallyAdjustedHeightTable).go();
        await db.delete(db.colsManuallyAdjustedWidthTable).go();
      });
    } on SqliteException catch (e) {
      throw CacheException('Failed to clear all data: ${e.message}');
    } catch (e) {
      throw CacheException('An unknown database error occurred.');
    }
  }
}
