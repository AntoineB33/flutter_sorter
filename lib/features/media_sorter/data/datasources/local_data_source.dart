// The Interface
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
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
    for (var item in items) {
      if (item is UpdateData) {
        UpdateData updateData = item;
        if (updateData.addOtherwiseRemove) {
          await db.into(db.updateHistories).insertOnConflictUpdate(
            UpdateHistoriesCompanion.insert(
              chronoId: updateData.chronoId,
              sheetId: updateData.sheetId,
              updates: updateData.toJson(),
              timestamp: updateData.timestamp,
            ),
          );
        } else {
          await (db.delete(db.updateHistories)
                ..where((tbl) =>
                    tbl.timestamp.equals(updateData.timestamp) &
                    tbl.chronoId.equals(updateData.chronoId) &
                    tbl.sheetId.equals(updateData.sheetId)))
              .go();
        }
      }
    }
  }
}