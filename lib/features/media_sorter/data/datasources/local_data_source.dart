import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:rxdart/rxdart.dart';
import 'package:trying_flutter/core/error/exceptions.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/update_data.dart';
import 'package:drift/drift.dart';
import 'package:trying_flutter/utils/logger.dart';

class SheetIdAndLastOpened {
  final int sheetId;
  final DateTime lastOpened;

  SheetIdAndLastOpened(this.sheetId, this.lastOpened);
}

abstract class ILocalDataSource {
  void saveUpdate(SyncRequest update);
  void save(ChangeSet updates);
  void dispose();
  Future<void> batchInsertOrUpdate(List<SyncRequest> syncRequests);
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

enum DataBaseOperationType { insert, update, delete }

class SyncRequest {
  final DbCompanionWrapper companion;
  final DataBaseOperationType dataBaseOperationType;

  SyncRequest(this.companion, this.dataBaseOperationType);

  SyncRequest merge(SyncRequest other) {
    if (other.dataBaseOperationType == DataBaseOperationType.delete) {
      return SyncRequest(other.companion, DataBaseOperationType.delete);
    } else {
      DbCompanionWrapper companion = this.companion;
      DataBaseOperationType dataBaseOperationType;
      if (this.dataBaseOperationType == DataBaseOperationType.delete) {
        companion = other.companion;
        if (other.dataBaseOperationType != DataBaseOperationType.insert) {
          throw Exception(
            "Invalid merge: cannot merge a delete with a non-insert operation",
          );
        }
        dataBaseOperationType = DataBaseOperationType.insert;
      } else {
        // For updates, we merge the maps. New values override old ones.
        final mergedMap = Map<String, Expression>.from(
          this.companion.companion.toColumns(false),
        )..addAll(other.companion.companion.toColumns(false));
        companion = RawValuesInsertable(mergedMap) as DbCompanionWrapper;
        if (this.dataBaseOperationType == DataBaseOperationType.insert) {
          dataBaseOperationType = DataBaseOperationType.insert;
        } else {
          if (other.dataBaseOperationType == DataBaseOperationType.insert) {
            throw Exception(
              "Invalid merge: cannot merge an update with an insert operation",
            );
          }
          dataBaseOperationType = DataBaseOperationType.update;
        }
      }
      return SyncRequest(companion, dataBaseOperationType);
    }
  }

  String getKey() {
    switch (companion) {
      case SheetDataWrapper():
        return "SheetDataTables:${(companion as SheetDataWrapper).companion.id.value}";
      case SheetCellWrapper():
        final cellCompanion = (companion as SheetCellWrapper).companion;
        return "SheetCellsTable:${cellCompanion.sheetId.value}-${cellCompanion.row.value}-${cellCompanion.col.value}";
    }
  }
}

class DriftLocalDataSource
    with WidgetsBindingObserver
    implements ILocalDataSource {
  final AppDatabase db;

  final ILocalDataSource _localDataSource;

  // The Map acts as our cache. Using the entity's ID as the key
  // guarantees the "latest wins" behavior automatically.
  final Map<String, SyncRequest> _pendingSaves = {};

  // The trigger for our debounce logic
  final PublishSubject<void> _saveTrigger = PublishSubject<void>();
  StreamSubscription? _saveSubscription;

  DriftLocalDataSource(this.db, this._localDataSource) {
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
  void saveUpdate(SyncRequest update) {
    save(ChangeSet()..addUpdate(update));
  }

  @override
  void save(ChangeSet updates) {
    for (var update in updates.toMap().values) {
      _pendingSaves.update(
        update.getKey(),
        (existing) => existing.merge(update),
        ifAbsent: () => update,
      );
      _saveTrigger.add(null);
    }
  }

  /// Takes the current cache, clears it, and writes to Drift
  Future<void> _flushToDatabase() async {
    if (_pendingSaves.isEmpty) return;

    // 1. Extract the items AND clear the map synchronously.
    // Doing this immediately prevents asynchronous race conditions where
    // a Use Case might add a new item while the DB is busy writing.
    final itemsToSave = _pendingSaves.values.toList();
    _pendingSaves.clear();

    // 2. Write to the database
    try {
      await _localDataSource.batchInsertOrUpdate(itemsToSave);
    } catch (e) {
      // ERROR HANDLING: If the save fails, we return the items to the cache.
      // We use putIfAbsent so we don't accidentally overwrite newer edits
      // that a user might have made while the DB was failing.
      for (var item in itemsToSave) {
        _pendingSaves.putIfAbsent(item.getKey(), () => item);
      }
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

  Value<T> _nullableToValue<T>(T? itemField) {
    return itemField != null ? Value(itemField) : const Value.absent();
  }

  void _executeBatchOperation<T extends Table, D>(
    Batch batch,
    TableInfo<T, D> table,
    SyncRequest syncRequest,
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
    }
  }

  @override
  Future<void> batchInsertOrUpdate(List<SyncRequest> syncRequests) async {
    await db.batch((batch) {
      for (final syncRequest in syncRequests) {
        switch (syncRequest.companion) {
          case SheetDataWrapper():
            _executeBatchOperation(batch, db.sheetDataTables, syncRequest);
            break;
          case SheetCellWrapper():
            _executeBatchOperation(batch, db.sheetCellsTable, syncRequest);
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
