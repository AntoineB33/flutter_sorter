// The Interface
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:drift/drift.dart';

abstract class ILocalDataSource {
  Future<void> batchInsertOrUpdate(List<UpdateUnit> items);
}

// The Implementation
class DriftLocalDataSource implements ILocalDataSource {
  final AppDatabase db;

  DriftLocalDataSource(this.db);

  @override
  Future<void> batchInsertOrUpdate(List<UpdateUnit> items) async {
    final cellUpserts = <SheetCellsCompanion>[];
    final cellDeletes = <SheetCellsCompanion>[];
    final columnTypeUpserts = <SheetColumnTypesCompanion>[];
    final columnTypeDeletes = <SheetColumnTypesCompanion>[];
    final historyUpserts = <UpdateHistoriesCompanion>[];
    final historyDeletes = <UpdateHistoriesCompanion>[];

    for (var item in items) {
      if (item is UpdateData) {
        UpdateData updateData = item;
        if (updateData.addOtherwiseRemove) {
          historyUpserts.add(UpdateHistoriesCompanion(
            sheetId: Value(updateData.sheetId),
            chronoId: Value(updateData.chronoId),
            timestamp: Value(updateData.timestamp),
            updates: Value(updateData.updates),
          ));
        } else {
          historyDeletes.add(UpdateHistoriesCompanion(
            sheetId: Value(updateData.sheetId),
            chronoId: Value(updateData.chronoId),
            timestamp: Value(updateData.timestamp),
          ));
        }
      } else if (item is CellUpdate) {
        // Create a companion object mapped to your SheetCells table
        final companion = SheetCellsCompanion(
          sheetId: Value(item.sheetId),
          row: Value(item.rowId),
          col: Value(item.colId),
          content: Value(item.newValue),
        );
        if (item.newValue.isEmpty) {
          cellDeletes.add(companion);
        } else {
          cellUpserts.add(companion);
        }
      } else if (item is ColumnTypeUpdate) {
        final companion = SheetColumnTypesCompanion(
          sheetId: Value(item.sheetId),
          columnIndex: Value(item.colId),
          columnType: Value(item.newColumnType.toString()),
        );
        if (item.newColumnType == ColumnType.attributes) {
          columnTypeDeletes.add(companion);
        } else {
          columnTypeUpserts.add(companion);
        }
      } else if () {
      }
    }

    // 2. Execute efficiently in a single batch transaction
    await db.batch((batch) {
      // Handle both inserts and updates simultaneously
      if (cellUpserts.isNotEmpty) {
        batch.insertAll(
          db.sheetCells,
          cellUpserts,
          mode: InsertMode.insertOrReplace,
        );
      }

      // Handle deletions
      for (final del in cellDeletes) {
        // Drift uses the primary key fields in the companion to find and delete the row
        batch.delete(db.sheetCells, del);
      }
    });
  }
}