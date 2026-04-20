import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:rxdart/rxdart.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:drift/drift.dart';
import 'package:trying_flutter/utils/logger.dart';

class SheetIdAndLastOpened {
  final int sheetId;
  final DateTime lastOpened;

  SheetIdAndLastOpened(this.sheetId, this.lastOpened);
}

abstract class ILocalDataSource {
  void save(List<SyncRequest> updates);
  void dispose();
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

class DriftLocalDataSource
    with WidgetsBindingObserver
    implements ILocalDataSource {
  final AppDatabase db;

  // The Map acts as our cache. Using the entity's ID as the key
  // guarantees the "latest wins" behavior automatically.
  final List<SyncRequestImpl> _pendingSaves = [];

  // The trigger for our debounce logic
  final PublishSubject<void> _saveTrigger = PublishSubject<void>();
  StreamSubscription? _saveSubscription;

  DriftLocalDataSource(this.db) {
    // Listen to app lifecycle changes (pause, background, etc.)
    WidgetsBinding.instance.addObserver(this);

    // Set up the debounce listener
    _saveSubscription = _saveTrigger
        .debounceTime(
          const Duration(milliseconds: 500),
        ) // Adjust time as needed
        .listen((_) => _flushToDatabase());
  }

  @override
  void save(List<SyncRequest> updates) {
    _pendingSaves.addAll(updates as List<SyncRequestImpl>);
    if (updates.isNotEmpty) {
      _saveTrigger.add(null);
    }
  }

  /// Takes the current cache, clears it, and writes to Drift
  Future<void> _flushToDatabase() async {
    if (_pendingSaves.isEmpty) return;

    // 1. Extract the items AND clear the map synchronously.
    // Doing this immediately prevents asynchronous race conditions where
    // a Use Case might add a new item while the DB is busy writing.
    final itemsToSave = _pendingSaves.toList();
    _pendingSaves.clear();

    // 2. Write to the database
    try {
      await _batchInsertOrUpdate(itemsToSave);
    } catch (e) {
      // ERROR HANDLING: If the save fails, we return the items to the cache.
      // We use putIfAbsent so we don't accidentally overwrite newer edits
      // that a user might have made while the DB was failing.
      _pendingSaves.addAll(itemsToSave);
      logger.e("Database save failed. Items returned to cache. Error: $e");
    }
  }

  /// App Lifecycle Hook
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the user minimizes the app or it gets killed, force a save immediately.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      logger.i("App going to background! Forcing emergency flush...");
      _flushToDatabase();
    }
  }

  /// Clean up when the repository is destroyed
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveSubscription?.cancel();
    _saveTrigger.close();
    // Do one final flush just in case
    _flushToDatabase();
  }

  void _executeBatchOperation<T extends Table, D>(
    Batch batch,
    TableInfo<T, D> table,
    SyncRequestImpl syncRequest,
  ) {
    switch (syncRequest.dataBaseOperationType) {
      case DataBaseOperationType.delete:
        batch.delete(table, syncRequest.companion.companion);
        break;
      case DataBaseOperationType.insert:
        batch.insert(
          table,
          syncRequest.companion.companion,
          mode: InsertMode.insertOrReplace,
        );
        break;
      case DataBaseOperationType.update:
        batch.update(table, syncRequest.companion.companion);
        break;
      case DataBaseOperationType.deleteWhere:
        // 1. Extract the explicitly set fields from the companion.
        // The 'false' argument ensures we include Value(null) if explicitly set.
        final presentColumns = syncRequest.companion.companion.toColumns(false);

        // If the companion is completely empty, skip to prevent wiping the whole table.
        if (presentColumns.isEmpty) return;

        Expression<bool>? filter;

        // 2. Iterate over the fields present in the companion.
        for (final entry in presentColumns.entries) {
          final columnName = entry.key;
          final valueExpression = entry.value;

          // 3. Look up the actual column object on the table.
          final tableColumn = table.columnsByName[columnName];

          if (tableColumn != null) {
            // 4. Build the SQL equality expression: (tableColumn = value)
            final condition = tableColumn.equalsExp(valueExpression);

            // 5. Chain multiple conditions together using the bitwise AND operator (&),
            // which Drift overrides to generate SQL's logical AND.
            if (filter == null) {
              filter = condition;
            } else {
              filter = filter & condition;
            }
          }
        }

        // 6. Apply the dynamic filter to the batch.
        if (filter != null) {
          batch.deleteWhere(table, (_) => filter!);
        }
        break;
    }
  }

  Future<void> _batchInsertOrUpdate(List<SyncRequestImpl> syncRequests) async {
    await db.batch((batch) {
      for (final syncRequest in syncRequests) {
        switch (syncRequest.companion) {
          case SheetDataWrapper():
            _executeBatchOperation(batch, db.sheetDataTables, syncRequest);
            break;
          case SheetCellWrapper():
            _executeBatchOperation(batch, db.sheetCellsTable, syncRequest);
            break;
          case HistoryWrapper():
            _executeBatchOperation(batch, db.updateHistoriesTable, syncRequest);
            break;
          case RowHeightWrapper():
            _executeBatchOperation(batch, db.rowsBottomPosTable, syncRequest);
            break;
          case ColWidthWrapper():
            _executeBatchOperation(batch, db.colRightPosTable, syncRequest);
            break;
          case RowsManuallyAdjustedHeightWrapper():
            _executeBatchOperation(
              batch,
              db.rowsManuallyAdjustedHeightTable,
              syncRequest,
            );
            break;
          case ColsManuallyAdjustedWidthWrapper():
            _executeBatchOperation(
              batch,
              db.colsManuallyAdjustedWidthTable,
              syncRequest,
            );
            break;
        }
      }
    });
  }

  @override
  Future<List<SheetIdAndLastOpened>> getSheetIdAndLastOpened() async {
    try {
      final query = db.selectOnly(db.sheetDataTables)
        ..addColumns([
          db.sheetDataTables.sheetId,
          db.sheetDataTables.lastOpened,
        ]);
      final result = await query.get();
      return result
          .map(
            (row) => SheetIdAndLastOpened(
              row.read(db.sheetDataTables.sheetId)!,
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
        ..where((table) => table.sheetId.equals(sheetId));
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
          db.sheetDataTables.sheetId,
          db.sheetDataTables.sortInProgress,
          db.sheetDataTables.toApplyNextBestSort,
          db.sheetDataTables.analysisDone,
        ])
        ..where(db.sheetDataTables.sortInProgress.equals(true));
      final result = await query.get();
      return result
          .map(
            (row) => SortStatusData(
              sheetId: row.read(db.sheetDataTables.sheetId)!,
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
