import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/core_sheet_content.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sort_status.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:drift/drift.dart';

abstract class ILocalDataSource {
  Future<void> batchInsertOrUpdate(List<UpdateUnit> items);
  Future<Either<Exception, CoreSheetContent>> getSheet(int sheetId);
  Future<Either<Exception, Map<int, SortStatus>>> getSortStatus();
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
            name: item.newName != null ? Value(item.newName!) : Value.absent(),
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
  Future<Either<Exception, CoreSheetContent>> getSheet(int sheetId) async {
    try {
      // 1. Start a selectOnly query
      final query = db.selectOnly(db.sheetDataTables)..where(db.sheetDataTables.id.equals(sheetId));

      // 4. Execute the query
      final coreSheetContents = await query.get();

      final cellQuery = db.select(db.sheetCells)..where((tbl) => tbl.sheetId.equals(sheetId));

      final sheetCells = await cellQuery.get();
      final cells = {
        for (var cell in sheetCells) CellPosition(cell.row, cell.col): cell.content,
      };

      final columnTypeQuery = db.select(db.sheetColumnTypes)..where((tbl) => tbl.sheetId.equals(sheetId));

      final columnTypes = {
        for (var colType in await columnTypeQuery.get()) colType.columnIndex: ColumnType.values.firstWhere((v) => v.name == colType.columnType),
      };
      
      final coreSheetContent = CoreSheetContent(
        id: sheetId,
        title: coreSheetContents.first.read(db.sheetDataTables.title)!,
        lastOpened: coreSheetContents.first.read(db.sheetDataTables.lastOpened)!,
        cells: cells,
        columnTypes: columnTypes,
      );

      return Right(coreSheetContent);
    } on Exception catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, Map<int, SortStatus>>> getSortStatus() async {
    try {
      // 1. Start a selectOnly query
      final query = db.selectOnly(db.sheetDataTables)
        // 2. Specify ALL the columns you need for the Map key and the SortStatus object
        ..addColumns([
          db.sheetDataTables.id,
          db.sheetDataTables.toApplyNextBestSort,
          db.sheetDataTables.toAlwaysApplyCurrentBestSort,
          db.sheetDataTables.analysisDone,
        ])
        // 3. Add your condition
        ..where(db.sheetDataTables.sortInProgress.equals(true));

      // 4. Execute the query
      final rows = await query.get();

      // 5. Map the raw rows into MapEntry objects, reading each column
      final entries = rows.map((row) {
        final id = row.read(db.sheetDataTables.id)!;
        
        final sortStatus = SortStatus(
          toApplyNextBestSort: row.read(db.sheetDataTables.toApplyNextBestSort) ?? false,
          toAlwaysApplyCurrentBestSort: row.read(db.sheetDataTables.toAlwaysApplyCurrentBestSort) ?? false,
          analysisDone: row.read(db.sheetDataTables.analysisDone) ?? true,
        );

        return MapEntry(id, sortStatus);
      });

      // 6. Convert the Iterable of MapEntries into the final Map
      final resultMap = Map.fromEntries(entries);

      return Right(resultMap);
    } on Exception catch (e) {
      return Left(e);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}