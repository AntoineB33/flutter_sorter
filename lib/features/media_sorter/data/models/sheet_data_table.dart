import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/data/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';
import 'package:drift/drift.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/node_struct.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/selection_data.dart';


class SyncRequestImpl implements SyncRequest {
  final DbCompanionWrapper companion;
  final DataBaseOperationType dataBaseOperationType;

  SyncRequestImpl(this.companion, this.dataBaseOperationType);

  SyncRequestImpl merge(SyncRequestImpl other) {
    if (other.dataBaseOperationType == DataBaseOperationType.delete) {
      return SyncRequestImpl(other.companion, DataBaseOperationType.delete);
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
      return SyncRequestImpl(companion, dataBaseOperationType);
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

sealed class DbCompanionWrapper {
  UpdateCompanion<DataClass> get companion;
}

class SheetDataWrapper extends DbCompanionWrapper {
  @override
  final SheetDataTablesCompanion companion;
  SheetDataWrapper(this.companion);
}

class SheetCellWrapper extends DbCompanionWrapper {
  @override
  final SheetCellsTableCompanion companion;
  SheetCellWrapper(this.companion);
}

class HistoryWrapper extends DbCompanionWrapper {
  @override
  final UpdateHistoriesTableCompanion companion;
  HistoryWrapper(this.companion);
}

@DataClassName('SheetDataEntity')
class SheetDataTables extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get lastOpened => dateTime()();
  TextColumn get usedRows => text().map(const ListIntConverter())();
  TextColumn get usedCols => text().map(const ListIntConverter())();
  IntColumn get historyIndex => integer()();
  RealColumn get colHeaderHeight => real()();
  RealColumn get rowHeaderWidth => real()();
  TextColumn get selectionHistory =>
      text().map(const SelectionDataConverter())();
  RealColumn get scrollOffsetX => real()();
  RealColumn get scrollOffsetY => real()();

  TextColumn get bestSortFound => text().map(const ListIntConverter())();
  TextColumn get bestDistFound => text().map(const ListIntConverter())();
  TextColumn get cursors => text().map(const ListIntConverter())();
  TextColumn get possibleInts => text().map(const ListListIntConverter())();
  TextColumn get validAreas => text().map(const ListListListIntConverter())();
  IntColumn get sortIndex => integer()();

  TextColumn get analysisResult =>
      text().map(const AnalysisResultConverter())();

  BoolColumn get sortInProgress => boolean()();
  BoolColumn get toAlwaysApplyCurrentBestSort => boolean()();
  BoolColumn get toApplyNextBestSort => boolean()();
  BoolColumn get analysisDone => boolean()();
}

@DataClassName('SheetCellEntity')
class SheetCellsTable extends Table {
  // Foreign key linking to the parent sheet
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();

  // The position
  IntColumn get row => integer()();
  IntColumn get col => integer()();

  // The content
  TextColumn get content => text()();

  // A sheet cannot have two cells at the exact same row/col position
  @override
  Set<Column> get primaryKey => {sheetId, row, col};
}

@DataClassName('SheetColumnTypeEntity')
class SheetColumnTypesTable extends Table {
  // Foreign key linking to the parent sheet
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();

  // The column index (0, 1, 2, etc.)
  IntColumn get columnIndex => integer()();

  // Drift magic: Stores the enum as an int in SQLite, but returns the Enum in Dart
  IntColumn get columnType => intEnum<ColumnType>()();

  // A sheet cannot have two different types defined for the same column index
  @override
  Set<Column> get primaryKey => {sheetId, columnIndex};
}

class ChangeSetMapConverter extends TypeConverter<ChangeSetImpl, String> {
  const ChangeSetMapConverter();

  @override
  ChangeSetImpl fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as Map<String, dynamic>;
    return ChangeSetImpl.fromJson(decoded);
  }

  @override
  String toSql(ChangeSetImpl value) {
    final encoded = value.toJson();
    return jsonEncode(encoded);
  }
}

@DataClassName('UpdateHistoriesEntity')
class UpdateHistoriesTable extends Table {
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get chronoId => integer()();
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  TextColumn get updates => text().map(const ChangeSetMapConverter())();

  @override
  Set<Column> get primaryKey => {timestamp, chronoId};
}

@DataClassName('RowsBottomPosEntity')
class RowsBottomPosTable extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  IntColumn get rowIndex => integer()();
  RealColumn get bottomPos => real()();

  @override
  Set<Column> get primaryKey => {sheetId, rowIndex};
}

@DataClassName('ColRightPosEntity')
class ColRightPosTable extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  IntColumn get colIndex => integer()();
  RealColumn get rightPos => real()();

  @override
  Set<Column> get primaryKey => {sheetId, colIndex};
}

@DataClassName('RowsManuallyAdjustedHeightEntity')
class RowsManuallyAdjustedHeightTable extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  IntColumn get rowIndex => integer()();
  BoolColumn get manuallyAdjusted => boolean()();

  @override
  Set<Column> get primaryKey => {sheetId, rowIndex};
}

@DataClassName('ColsManuallyAdjustedWidthEntity')
class ColsManuallyAdjustedWidthTable extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  IntColumn get colIndex => integer()();
  BoolColumn get manuallyAdjusted => boolean()();

  @override
  Set<Column> get primaryKey => {sheetId, colIndex};
}

class NodeStructListConverter extends TypeConverter<List<NodeStruct>, String> {
  const NodeStructListConverter();

  @override
  List<NodeStruct> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded
        .map((e) => NodeStruct.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<NodeStruct> value) {
    final encoded = value.map((e) => e.toJson()).toList();
    return jsonEncode(encoded);
  }
}

class SelectionDataConverter extends TypeConverter<SelectionData, String> {
  const SelectionDataConverter();

  @override
  SelectionData fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as Map<String, dynamic>;
    return SelectionData.fromJson(decoded);
  }

  @override
  String toSql(SelectionData value) {
    final encoded = value.toJson();
    return jsonEncode(encoded);
  }
}

class SetPointConverter extends TypeConverter<Set<CellPosition>, String> {
  const SetPointConverter();

  @override
  Set<CellPosition> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded.map((e) => CellPosition(e[0] as int, e[1] as int)).toSet();
  }

  @override
  String toSql(Set<CellPosition> value) {
    final encoded = value.map((e) => [e.rowId, e.colId]).toList();
    return jsonEncode(encoded);
  }
}

class ListPointConverter extends TypeConverter<List<CellPosition>, String> {
  const ListPointConverter();

  @override
  List<CellPosition> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded.map((e) => CellPosition(e[0] as int, e[1] as int)).toList();
  }

  @override
  String toSql(List<CellPosition> value) {
    final encoded = value.map((e) => [e.rowId, e.colId]).toList();
    return jsonEncode(encoded);
  }
}

class ListIntConverter extends TypeConverter<List<int>, String> {
  const ListIntConverter();

  @override
  List<int> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded.map((e) => e as int).toList();
  }

  @override
  String toSql(List<int> value) {
    return jsonEncode(value);
  }
}

class ListListIntConverter extends TypeConverter<List<List<int>>, String> {
  const ListListIntConverter();

  @override
  List<List<int>> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded
        .map((e) => (e as List<dynamic>).map((i) => i as int).toList())
        .toList();
  }

  @override
  String toSql(List<List<int>> value) {
    return jsonEncode(value);
  }
}

class ListListListIntConverter
    extends TypeConverter<List<List<List<int>>>, String> {
  const ListListListIntConverter();

  @override
  List<List<List<int>>> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded
        .map(
          (e) => (e as List<dynamic>)
              .map((l) => (l as List<dynamic>).map((i) => i as int).toList())
              .toList(),
        )
        .toList();
  }

  @override
  String toSql(List<List<List<int>>> value) {
    return jsonEncode(value);
  }
}

class AnalysisResultConverter extends TypeConverter<AnalysisResult, String> {
  const AnalysisResultConverter();

  @override
  AnalysisResult fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as Map<String, dynamic>;
    return AnalysisResult.fromJson(decoded);
  }

  @override
  String toSql(AnalysisResult value) {
    final encoded = value.toJson();
    return jsonEncode(encoded);
  }
}

class SortStatusData {
  final int sheetId;
  final bool toApplyNextBestSort;
  final bool analysisDone;

  SortStatusData({
    required this.sheetId,
    required this.toApplyNextBestSort,
    required this.analysisDone,
  });
}
