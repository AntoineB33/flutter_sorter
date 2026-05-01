import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';
import 'package:drift/drift.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/node_struct.dart';

part 'sheet_data_table.freezed.dart';

@freezed
@JsonSerializable(explicitToJson: true)
class SyncRequestWithoutHistImpl implements SyncRequestWithoutHist {
  final DbCompanionWrapper companionWrapper;
  final DataBaseOperationType dataBaseOperationType;

  SyncRequestWithoutHistImpl(this.companionWrapper, this.dataBaseOperationType);

  factory SyncRequestWithoutHistImpl.fromJson(Map<String, dynamic> json) =>
      _$SyncRequestImplFromJson(json);
  Map<String, dynamic> toJson() => _$SyncRequestImplToJson(this);
  // ignore: unused_element
  static void _keepLinterHappy() => SyncRequestWithoutHistImpl(
    SheetDataWrapper(SheetDataTablesCompanion()),
    DataBaseOperationType.insert,
  ).toJson();
}

@freezed
@JsonSerializable(explicitToJson: true)
class SyncRequestWithHistImpl implements SyncRequestWithHist {
  final DbCompanionWrapperNotHistory companionWrapper;
  final DbCompanionWrapperNotHistory historyCompW;
  final DataBaseOperationType dataBaseOperationType;

  SyncRequestWithHistImpl(
    this.companionWrapper,
    this.historyCompW,
    this.dataBaseOperationType,
  );

  factory SyncRequestWithHistImpl.fromJson(Map<String, dynamic> json) =>
      _$SyncRequestWithHistImplFromJson(json);
  Map<String, dynamic> toJson() => _$SyncRequestWithHistImplToJson(this);
  // ignore: unused_element
  static void _keepLinterHappy() => SyncRequestWithHistImpl(
    SheetDataWrapper(SheetDataTablesCompanion()),
    SheetDataWrapper(SheetDataTablesCompanion()),
    DataBaseOperationType.insert,
  ).toJson();

  SyncRequestWithoutHistImpl toSyncRequest() {
    return SyncRequestWithoutHistImpl(
      companionWrapper as DbCompanionWrapper,
      dataBaseOperationType,
    );
  }
}

// wrapper stored in syncRequest to separate the domain (syncRequest) from the data layer (the companions)
@JsonSerializable(explicitToJson: true)
sealed class DbCompanionWrapper {
  DbCompanionWrapper();

  UpdateCompanion<DataClass> get companion;

  factory DbCompanionWrapper.fromJson(Map<String, dynamic> json) =>
      _$DbCompanionWrapperFromJson(json);
  Map<String, dynamic> toJson() => _$DbCompanionWrapperToJson(this);
  // ignore: unused_element
  static void _keepLinterHappy() =>
      SheetDataWrapper(SheetDataTablesCompanion()).toJson();
}

sealed class DbCompanionWrapperNotHistory extends DbCompanionWrapper {}

class SheetDataWrapper extends DbCompanionWrapperNotHistory {
  @override
  final SheetDataTablesCompanion companion;
  SheetDataWrapper(this.companion);
}

class SheetCellWrapper extends DbCompanionWrapperNotHistory {
  @override
  final SheetCellsTableCompanion companion;
  SheetCellWrapper(this.companion);
}

class HistoryWrapper extends DbCompanionWrapper {
  @override
  final UpdateHistoriesTableCompanion companion;
  HistoryWrapper(this.companion);
}

class RowHeightWrapper extends DbCompanionWrapperNotHistory {
  @override
  final RowsBottomPosTableCompanion companion;
  RowHeightWrapper(this.companion);
}

class ColWidthWrapper extends DbCompanionWrapperNotHistory {
  @override
  final ColRightPosTableCompanion companion;
  ColWidthWrapper(this.companion);
}

class RowsManuallyAdjustedHeightWrapper extends DbCompanionWrapperNotHistory {
  @override
  final RowsManuallyAdjustedHeightTableCompanion companion;
  RowsManuallyAdjustedHeightWrapper(this.companion);
}

class ColsManuallyAdjustedWidthWrapper extends DbCompanionWrapperNotHistory {
  @override
  final ColsManuallyAdjustedWidthTableCompanion companion;
  ColsManuallyAdjustedWidthWrapper(this.companion);
}

@DataClassName('SheetDataEntity')
class SheetDataTables extends Table {
  IntColumn get sheetId => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get lastOpened => dateTime()();
  TextColumn get usedRows => text().map(const ListIntConverter())();
  TextColumn get usedCols => text().map(const ListIntConverter())();
  IntColumn get historyIndex => integer()();
  RealColumn get colHeaderHeight => real()();
  RealColumn get rowHeaderWidth => real()();
  
  IntColumn get primarySelectionX => integer()();
  IntColumn get primarySelectionY => integer()();
  TextColumn get selectedCells => text().map(const SetCellPositionConverter())();
  IntColumn get selectionHistoryId => integer()();
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

  BoolColumn get editingModeHist => boolean()();

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

class ListSyncRequestMapConverter
    extends TypeConverter<List<SyncRequest>, String> {
  const ListSyncRequestMapConverter();

  @override
  List<SyncRequest> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded
        .map(
          (e) => SyncRequestWithoutHistImpl.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  String toSql(List<SyncRequest> value) {
    final encoded = value
        .map((e) => (e as SyncRequestWithoutHistImpl).toJson())
        .toList();
    return jsonEncode(encoded);
  }
}

@DataClassName('UpdateHistoriesEntity')
class UpdateHistoriesTable extends Table {
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get chronoId => integer()();
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  TextColumn get updates => text().map(const ListSyncRequestMapConverter())();

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

class CellPositionConverter extends TypeConverter<CellPosition, String> {
  const CellPositionConverter();

  @override
  CellPosition fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return CellPosition(decoded[0] as int, decoded[1] as int);
  }

  @override
  String toSql(CellPosition value) {
    final encoded = [value.rowId, value.colId];
    return jsonEncode(encoded);
  }
}

class SetCellPositionConverter extends TypeConverter<Set<CellPosition>, String> {
  const SetCellPositionConverter();

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
