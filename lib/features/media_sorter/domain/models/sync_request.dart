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
