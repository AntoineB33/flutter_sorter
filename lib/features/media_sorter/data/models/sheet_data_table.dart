import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:trying_flutter/features/media_sorter/data/datasources/app_database.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/cell_position.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';
import 'package:drift/drift.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/node_struct.dart';

part 'sheet_data_table.g.dart';

enum DataBaseOperationType { insert, update, delete, deleteWhere }

@JsonSerializable(explicitToJson: true)
class SyncRequestWithoutHist {
  final DbCompanionWrapper companionWrapper;
  final DataBaseOperationType dataBaseOperationType;

  SyncRequestWithoutHist(this.companionWrapper, this.dataBaseOperationType);

  factory SyncRequestWithoutHist.fromJson(Map<String, dynamic> json) =>
      _$SyncRequestWithoutHistFromJson(json);
  Map<String, dynamic> toJson() => _$SyncRequestWithoutHistToJson(this);
  // ignore: unused_element
  static void _keepLinterHappy() => SyncRequestWithoutHist(
    SheetDataWrapper(0, SheetDataTablesCompanion()),
    DataBaseOperationType.insert,
  ).toJson();
}

// wrapper stored in syncRequest to separate the domain (syncRequest) from the data layer (the companions)
sealed class DbCompanionWrapper {
  DbCompanionWrapper();

  UpdateCompanion<DataClass> get companion;
  String get getKey;

  Map<String, dynamic> toJson() => {
    'key': getKey,
    'data': switch (this) {
      SheetDataWrapper(:final companion) =>
        _sheetDataTablesCompanionToJson(companion),
      SheetCellWrapper(:final companion) =>
        _sheetCellsTableCompanionToJson(companion),
      HistoryWrapper(:final companion) =>
        _updateHistoriesTableCompanionToJson(companion),
      RowHeightWrapper(:final companion) =>
        _rowsBottomPosTableCompanionToJson(companion),
      ColWidthWrapper(:final companion) =>
        _colRightPosTableCompanionToJson(companion),
      RowsManuallyAdjustedHeightWrapper(:final companion) =>
        _rowsManuallyAdjustedHeightTableCompanionToJson(companion),
      ColsManuallyAdjustedWidthWrapper(:final companion) =>
        _colsManuallyAdjustedWidthTableCompanionToJson(companion),
    },
  };

  factory DbCompanionWrapper.fromJson(Map<String, dynamic> json) {
    final key = json['key'] as String;
    final data = json['data'] as Map<String, dynamic>;
    return switch (key) {
      'SheetData' => SheetDataWrapper.fromJsonData(data),
      'SheetCells' => SheetCellWrapper.fromJsonData(data),
      'History' => HistoryWrapper.fromJsonData(data),
      'RowHeight' => RowHeightWrapper.fromJsonData(data),
      'ColWidth' => ColWidthWrapper.fromJsonData(data),
      'RowsManuallyAdjustedHeight' =>
        RowsManuallyAdjustedHeightWrapper.fromJsonData(data),
      'ColsManuallyAdjustedWidth' =>
        ColsManuallyAdjustedWidthWrapper.fromJsonData(data),
      _ => throw FormatException('Unknown DbCompanionWrapper key: $key'),
    };
  }

  // ignore: unused_element
  static void _keepLinterHappy() =>
      SheetDataWrapper(0, SheetDataTablesCompanion()).toJson();
}

sealed class DbCompanionWrapperNotHistory extends DbCompanionWrapper {}

class SheetDataWrapper extends DbCompanionWrapperNotHistory {
  @override
  String get getKey => "SheetData";
  @override
  final SheetDataTablesCompanion companion;
  SheetDataWrapper(int sheetId, SheetDataTablesCompanion companion)
    : companion = companion.copyWith(sheetId: Value(sheetId));

  factory SheetDataWrapper.fromJsonData(Map<String, dynamic> data) {
    final c = _sheetDataTablesCompanionFromJson(data);
    final sid = (data['sheetId'] as num?)?.toInt() ?? c.sheetId.value;
    return SheetDataWrapper(sid, c);
  }
}

class SheetCellWrapper extends DbCompanionWrapperNotHistory {
  @override
  String get getKey => "SheetCells";
  @override
  final SheetCellsTableCompanion companion;
  SheetCellWrapper(
    int sheetId,
    int row,
    int col,
    SheetCellsTableCompanion companion,
  ) : companion = companion.copyWith(
        sheetId: Value(sheetId),
        row: Value(row),
        col: Value(col),
      );

  factory SheetCellWrapper.fromJsonData(Map<String, dynamic> data) {
    final c = _sheetCellsTableCompanionFromJson(data);
    return SheetCellWrapper(
      (data['sheetId'] as num?)?.toInt() ?? c.sheetId.value,
      (data['row'] as num?)?.toInt() ?? c.row.value,
      (data['col'] as num?)?.toInt() ?? c.col.value,
      c,
    );
  }
}

class HistoryWrapper extends DbCompanionWrapper {
  @override
  String get getKey => "History";
  @override
  final UpdateHistoriesTableCompanion companion;
  HistoryWrapper(this.companion);

  factory HistoryWrapper.fromJsonData(Map<String, dynamic> data) {
    return HistoryWrapper(_updateHistoriesTableCompanionFromJson(data));
  }
}

class RowHeightWrapper extends DbCompanionWrapperNotHistory {
  @override
  String get getKey => "RowHeight";
  @override
  final RowsBottomPosTableCompanion companion;
  RowHeightWrapper(this.companion);

  factory RowHeightWrapper.fromJsonData(Map<String, dynamic> data) {
    return RowHeightWrapper(_rowsBottomPosTableCompanionFromJson(data));
  }
}

class ColWidthWrapper extends DbCompanionWrapperNotHistory {
  @override
  String get getKey => "ColWidth";
  @override
  final ColRightPosTableCompanion companion;
  ColWidthWrapper(this.companion);

  factory ColWidthWrapper.fromJsonData(Map<String, dynamic> data) {
    return ColWidthWrapper(_colRightPosTableCompanionFromJson(data));
  }
}

class RowsManuallyAdjustedHeightWrapper extends DbCompanionWrapperNotHistory {
  @override
  String get getKey => "RowsManuallyAdjustedHeight";
  @override
  final RowsManuallyAdjustedHeightTableCompanion companion;
  RowsManuallyAdjustedHeightWrapper(this.companion);

  factory RowsManuallyAdjustedHeightWrapper.fromJsonData(
    Map<String, dynamic> data,
  ) {
    return RowsManuallyAdjustedHeightWrapper(
      _rowsManuallyAdjustedHeightTableCompanionFromJson(data),
    );
  }
}

class ColsManuallyAdjustedWidthWrapper extends DbCompanionWrapperNotHistory {
  @override
  String get getKey => "ColsManuallyAdjustedWidth";
  @override
  final ColsManuallyAdjustedWidthTableCompanion companion;
  ColsManuallyAdjustedWidthWrapper(this.companion);

  factory ColsManuallyAdjustedWidthWrapper.fromJsonData(
    Map<String, dynamic> data,
  ) {
    return ColsManuallyAdjustedWidthWrapper(
      _colsManuallyAdjustedWidthTableCompanionFromJson(data),
    );
  }
}

List<int> _asIntList(Object? o) =>
    (o as List<dynamic>).map((e) => (e as num).toInt()).toList();

List<List<int>> _asIntListList(Object? o) => (o as List<dynamic>)
    .map((e) => (e as List<dynamic>).map((x) => (x as num).toInt()).toList())
    .toList();

List<List<List<int>>> _asIntListListList(Object? o) => (o as List<dynamic>)
    .map(
      (e) => (e as List<dynamic>)
          .map(
            (row) =>
                (row as List<dynamic>).map((x) => (x as num).toInt()).toList(),
          )
          .toList(),
    )
    .toList();

HistoryType _historyTypeFromString(String s) =>
    HistoryType.values.firstWhere((e) => e.toString() == s);

Map<String, dynamic> _sheetDataTablesCompanionToJson(
  SheetDataTablesCompanion c,
) {
  final m = <String, dynamic>{};
  if (c.sheetId.present) m['sheetId'] = c.sheetId.value;
  if (c.title.present) m['title'] = c.title.value;
  if (c.lastOpened.present) {
    m['lastOpened'] = c.lastOpened.value.toIso8601String();
  }
  if (c.usedRows.present) m['usedRows'] = c.usedRows.value;
  if (c.usedCols.present) m['usedCols'] = c.usedCols.value;
  if (c.historyIndex.present) m['historyIndex'] = c.historyIndex.value;
  if (c.colHeaderHeight.present) m['colHeaderHeight'] = c.colHeaderHeight.value;
  if (c.rowHeaderWidth.present) m['rowHeaderWidth'] = c.rowHeaderWidth.value;
  if (c.primarySelectionX.present) {
    m['primarySelectionX'] = c.primarySelectionX.value;
  }
  if (c.primarySelectionY.present) {
    m['primarySelectionY'] = c.primarySelectionY.value;
  }
  if (c.selectedCells.present) {
    m['selectedCells'] = c.selectedCells.value
        .map((e) => e.toJson())
        .toList();
  }
  if (c.selectionHistoryId.present) {
    m['selectionHistoryId'] = c.selectionHistoryId.value;
  }
  if (c.scrollOffsetX.present) m['scrollOffsetX'] = c.scrollOffsetX.value;
  if (c.scrollOffsetY.present) m['scrollOffsetY'] = c.scrollOffsetY.value;
  if (c.bestSortFound.present) m['bestSortFound'] = c.bestSortFound.value;
  if (c.bestDistFound.present) m['bestDistFound'] = c.bestDistFound.value;
  if (c.cursors.present) m['cursors'] = c.cursors.value;
  if (c.possibleInts.present) m['possibleInts'] = c.possibleInts.value;
  if (c.validAreas.present) m['validAreas'] = c.validAreas.value;
  if (c.sortIndex.present) m['sortIndex'] = c.sortIndex.value;
  if (c.analysisResult.present) {
    m['analysisResult'] = c.analysisResult.value.toJson();
  }
  if (c.sortInProgress.present) m['sortInProgress'] = c.sortInProgress.value;
  if (c.toAlwaysApplyCurrentBestSort.present) {
    m['toAlwaysApplyCurrentBestSort'] = c.toAlwaysApplyCurrentBestSort.value;
  }
  if (c.toApplyNextBestSort.present) {
    m['toApplyNextBestSort'] = c.toApplyNextBestSort.value;
  }
  if (c.analysisDone.present) m['analysisDone'] = c.analysisDone.value;
  return m;
}

SheetDataTablesCompanion _sheetDataTablesCompanionFromJson(
  Map<String, dynamic> j,
) {
  return SheetDataTablesCompanion(
    sheetId: j.containsKey('sheetId')
        ? Value((j['sheetId'] as num).toInt())
        : const Value.absent(),
    title: j.containsKey('title')
        ? Value(j['title'] as String)
        : const Value.absent(),
    lastOpened: j.containsKey('lastOpened')
        ? Value(DateTime.parse(j['lastOpened'] as String))
        : const Value.absent(),
    usedRows: j.containsKey('usedRows')
        ? Value(_asIntList(j['usedRows']))
        : const Value.absent(),
    usedCols: j.containsKey('usedCols')
        ? Value(_asIntList(j['usedCols']))
        : const Value.absent(),
    historyIndex: j.containsKey('historyIndex')
        ? Value((j['historyIndex'] as num).toInt())
        : const Value.absent(),
    colHeaderHeight: j.containsKey('colHeaderHeight')
        ? Value((j['colHeaderHeight'] as num).toDouble())
        : const Value.absent(),
    rowHeaderWidth: j.containsKey('rowHeaderWidth')
        ? Value((j['rowHeaderWidth'] as num).toDouble())
        : const Value.absent(),
    primarySelectionX: j.containsKey('primarySelectionX')
        ? Value((j['primarySelectionX'] as num).toInt())
        : const Value.absent(),
    primarySelectionY: j.containsKey('primarySelectionY')
        ? Value((j['primarySelectionY'] as num).toInt())
        : const Value.absent(),
    selectedCells: j.containsKey('selectedCells')
        ? Value(
            (j['selectedCells'] as List<dynamic>)
                .map((e) => CellPosition.fromJson(e as Map<String, dynamic>))
                .toSet(),
          )
        : const Value.absent(),
    selectionHistoryId: j.containsKey('selectionHistoryId')
        ? Value((j['selectionHistoryId'] as num).toInt())
        : const Value.absent(),
    scrollOffsetX: j.containsKey('scrollOffsetX')
        ? Value((j['scrollOffsetX'] as num).toDouble())
        : const Value.absent(),
    scrollOffsetY: j.containsKey('scrollOffsetY')
        ? Value((j['scrollOffsetY'] as num).toDouble())
        : const Value.absent(),
    bestSortFound: j.containsKey('bestSortFound')
        ? Value(_asIntList(j['bestSortFound']))
        : const Value.absent(),
    bestDistFound: j.containsKey('bestDistFound')
        ? Value(_asIntList(j['bestDistFound']))
        : const Value.absent(),
    cursors: j.containsKey('cursors')
        ? Value(_asIntList(j['cursors']))
        : const Value.absent(),
    possibleInts: j.containsKey('possibleInts')
        ? Value(_asIntListList(j['possibleInts']))
        : const Value.absent(),
    validAreas: j.containsKey('validAreas')
        ? Value(_asIntListListList(j['validAreas']))
        : const Value.absent(),
    sortIndex: j.containsKey('sortIndex')
        ? Value((j['sortIndex'] as num).toInt())
        : const Value.absent(),
    analysisResult: j.containsKey('analysisResult')
        ? Value(
            AnalysisResult.fromJson(
              j['analysisResult'] as Map<String, dynamic>,
            ),
          )
        : const Value.absent(),
    sortInProgress: j.containsKey('sortInProgress')
        ? Value(j['sortInProgress'] as bool)
        : const Value.absent(),
    toAlwaysApplyCurrentBestSort: j.containsKey('toAlwaysApplyCurrentBestSort')
        ? Value(j['toAlwaysApplyCurrentBestSort'] as bool)
        : const Value.absent(),
    toApplyNextBestSort: j.containsKey('toApplyNextBestSort')
        ? Value(j['toApplyNextBestSort'] as bool)
        : const Value.absent(),
    analysisDone: j.containsKey('analysisDone')
        ? Value(j['analysisDone'] as bool)
        : const Value.absent(),
  );
}

Map<String, dynamic> _sheetCellsTableCompanionToJson(
  SheetCellsTableCompanion c,
) {
  final m = <String, dynamic>{};
  if (c.sheetId.present) m['sheetId'] = c.sheetId.value;
  if (c.row.present) m['row'] = c.row.value;
  if (c.col.present) m['col'] = c.col.value;
  if (c.content.present) m['content'] = c.content.value;
  if (c.rowid.present) m['rowid'] = c.rowid.value;
  return m;
}

SheetCellsTableCompanion _sheetCellsTableCompanionFromJson(
  Map<String, dynamic> j,
) {
  return SheetCellsTableCompanion(
    sheetId: j.containsKey('sheetId')
        ? Value((j['sheetId'] as num).toInt())
        : const Value.absent(),
    row: j.containsKey('row')
        ? Value((j['row'] as num).toInt())
        : const Value.absent(),
    col: j.containsKey('col')
        ? Value((j['col'] as num).toInt())
        : const Value.absent(),
    content: j.containsKey('content')
        ? Value(j['content'] as String)
        : const Value.absent(),
    rowid: j.containsKey('rowid')
        ? Value((j['rowid'] as num).toInt())
        : const Value.absent(),
  );
}

Map<String, dynamic> _updateHistoriesTableCompanionToJson(
  UpdateHistoriesTableCompanion c,
) {
  final m = <String, dynamic>{};
  if (c.timestamp.present) {
    m['timestamp'] = c.timestamp.value.toIso8601String();
  }
  if (c.chronoId.present) m['chronoId'] = c.chronoId.value;
  if (c.sheetId.present) m['sheetId'] = c.sheetId.value;
  if (c.updates.present) {
    m['updates'] = c.updates.value.map((e) => e.toJson()).toList();
  }
  if (c.type.present) m['type'] = c.type.value.toString();
  if (c.rowid.present) m['rowid'] = c.rowid.value;
  return m;
}

UpdateHistoriesTableCompanion _updateHistoriesTableCompanionFromJson(
  Map<String, dynamic> j,
) {
  return UpdateHistoriesTableCompanion(
    timestamp: j.containsKey('timestamp')
        ? Value(DateTime.parse(j['timestamp'] as String))
        : const Value.absent(),
    chronoId: j.containsKey('chronoId')
        ? Value((j['chronoId'] as num).toInt())
        : const Value.absent(),
    sheetId: j.containsKey('sheetId')
        ? Value((j['sheetId'] as num).toInt())
        : const Value.absent(),
    updates: j.containsKey('updates')
        ? Value(
            (j['updates'] as List<dynamic>)
                .map((e) => SyncRequestWithoutHist.fromJson(e as Map<String, dynamic>))
                .toList(),
          )
        : const Value.absent(),
    type: j.containsKey('type')
        ? Value(_historyTypeFromString(j['type'] as String))
        : const Value.absent(),
    rowid: j.containsKey('rowid')
        ? Value((j['rowid'] as num).toInt())
        : const Value.absent(),
  );
}

Map<String, dynamic> _rowsBottomPosTableCompanionToJson(
  RowsBottomPosTableCompanion c,
) {
  final m = <String, dynamic>{};
  if (c.sheetId.present) m['sheetId'] = c.sheetId.value;
  if (c.rowIndex.present) m['rowIndex'] = c.rowIndex.value;
  if (c.bottomPos.present) m['bottomPos'] = c.bottomPos.value;
  if (c.rowid.present) m['rowid'] = c.rowid.value;
  return m;
}

RowsBottomPosTableCompanion _rowsBottomPosTableCompanionFromJson(
  Map<String, dynamic> j,
) {
  return RowsBottomPosTableCompanion(
    sheetId: j.containsKey('sheetId')
        ? Value((j['sheetId'] as num).toInt())
        : const Value.absent(),
    rowIndex: j.containsKey('rowIndex')
        ? Value((j['rowIndex'] as num).toInt())
        : const Value.absent(),
    bottomPos: j.containsKey('bottomPos')
        ? Value((j['bottomPos'] as num).toDouble())
        : const Value.absent(),
    rowid: j.containsKey('rowid')
        ? Value((j['rowid'] as num).toInt())
        : const Value.absent(),
  );
}

Map<String, dynamic> _colRightPosTableCompanionToJson(
  ColRightPosTableCompanion c,
) {
  final m = <String, dynamic>{};
  if (c.sheetId.present) m['sheetId'] = c.sheetId.value;
  if (c.colIndex.present) m['colIndex'] = c.colIndex.value;
  if (c.rightPos.present) m['rightPos'] = c.rightPos.value;
  if (c.rowid.present) m['rowid'] = c.rowid.value;
  return m;
}

ColRightPosTableCompanion _colRightPosTableCompanionFromJson(
  Map<String, dynamic> j,
) {
  return ColRightPosTableCompanion(
    sheetId: j.containsKey('sheetId')
        ? Value((j['sheetId'] as num).toInt())
        : const Value.absent(),
    colIndex: j.containsKey('colIndex')
        ? Value((j['colIndex'] as num).toInt())
        : const Value.absent(),
    rightPos: j.containsKey('rightPos')
        ? Value((j['rightPos'] as num).toDouble())
        : const Value.absent(),
    rowid: j.containsKey('rowid')
        ? Value((j['rowid'] as num).toInt())
        : const Value.absent(),
  );
}

Map<String, dynamic> _rowsManuallyAdjustedHeightTableCompanionToJson(
  RowsManuallyAdjustedHeightTableCompanion c,
) {
  final m = <String, dynamic>{};
  if (c.sheetId.present) m['sheetId'] = c.sheetId.value;
  if (c.rowIndex.present) m['rowIndex'] = c.rowIndex.value;
  if (c.manuallyAdjusted.present) {
    m['manuallyAdjusted'] = c.manuallyAdjusted.value;
  }
  if (c.rowid.present) m['rowid'] = c.rowid.value;
  return m;
}

RowsManuallyAdjustedHeightTableCompanion
_rowsManuallyAdjustedHeightTableCompanionFromJson(Map<String, dynamic> j) {
  return RowsManuallyAdjustedHeightTableCompanion(
    sheetId: j.containsKey('sheetId')
        ? Value((j['sheetId'] as num).toInt())
        : const Value.absent(),
    rowIndex: j.containsKey('rowIndex')
        ? Value((j['rowIndex'] as num).toInt())
        : const Value.absent(),
    manuallyAdjusted: j.containsKey('manuallyAdjusted')
        ? Value(j['manuallyAdjusted'] as bool)
        : const Value.absent(),
    rowid: j.containsKey('rowid')
        ? Value((j['rowid'] as num).toInt())
        : const Value.absent(),
  );
}

Map<String, dynamic> _colsManuallyAdjustedWidthTableCompanionToJson(
  ColsManuallyAdjustedWidthTableCompanion c,
) {
  final m = <String, dynamic>{};
  if (c.sheetId.present) m['sheetId'] = c.sheetId.value;
  if (c.colIndex.present) m['colIndex'] = c.colIndex.value;
  if (c.manuallyAdjusted.present) {
    m['manuallyAdjusted'] = c.manuallyAdjusted.value;
  }
  if (c.rowid.present) m['rowid'] = c.rowid.value;
  return m;
}

ColsManuallyAdjustedWidthTableCompanion
_colsManuallyAdjustedWidthTableCompanionFromJson(Map<String, dynamic> j) {
  return ColsManuallyAdjustedWidthTableCompanion(
    sheetId: j.containsKey('sheetId')
        ? Value((j['sheetId'] as num).toInt())
        : const Value.absent(),
    colIndex: j.containsKey('colIndex')
        ? Value((j['colIndex'] as num).toInt())
        : const Value.absent(),
    manuallyAdjusted: j.containsKey('manuallyAdjusted')
        ? Value(j['manuallyAdjusted'] as bool)
        : const Value.absent(),
    rowid: j.containsKey('rowid')
        ? Value((j['rowid'] as num).toInt())
        : const Value.absent(),
  );
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
  TextColumn get selectedCells =>
      text().map(const SetCellPositionConverter())();
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
  IntColumn get sheetId => integer().references(SheetDataTables, #sheetId)();

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
  IntColumn get sheetId => integer().references(SheetDataTables, #sheetId)();

  // The column index (0, 1, 2, etc.)
  IntColumn get columnIndex => integer()();

  // Drift magic: Stores the enum as an int in SQLite, but returns the Enum in Dart
  IntColumn get columnType => intEnum<ColumnType>()();

  // A sheet cannot have two different types defined for the same column index
  @override
  Set<Column> get primaryKey => {sheetId, columnIndex};
}

class HistoryChangeTypeConverter extends TypeConverter<HistoryType, String> {
  const HistoryChangeTypeConverter();

  @override
  HistoryType fromSql(String fromDb) {
    return HistoryType.values.firstWhere((e) => e.toString() == fromDb);
  }

  @override
  String toSql(HistoryType value) {
    return value.toString();
  }
}

class ListSyncRequestMapConverter
    extends TypeConverter<List<SyncRequestWithoutHist>, String> {
  const ListSyncRequestMapConverter();

  @override
  List<SyncRequestWithoutHist> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as List<dynamic>;
    return decoded
        .map((e) => SyncRequestWithoutHist.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<SyncRequestWithoutHist> value) {
    final encoded = value.map((e) => (e).toJson()).toList();
    return jsonEncode(encoded);
  }
}

@DataClassName('UpdateHistoriesEntity')
class UpdateHistoriesTable extends Table {
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get chronoId => integer()();
  IntColumn get sheetId => integer().references(SheetDataTables, #sheetId)();
  TextColumn get updates => text().map(const ListSyncRequestMapConverter())();
  TextColumn get type => text().map(const HistoryChangeTypeConverter())();

  @override
  Set<Column> get primaryKey => {timestamp, chronoId};
}

@DataClassName('RowsBottomPosEntity')
class RowsBottomPosTable extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #sheetId)();
  IntColumn get rowIndex => integer()();
  RealColumn get bottomPos => real()();

  @override
  Set<Column> get primaryKey => {sheetId, rowIndex};
}

@DataClassName('ColRightPosEntity')
class ColRightPosTable extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #sheetId)();
  IntColumn get colIndex => integer()();
  RealColumn get rightPos => real()();

  @override
  Set<Column> get primaryKey => {sheetId, colIndex};
}

@DataClassName('RowsManuallyAdjustedHeightEntity')
class RowsManuallyAdjustedHeightTable extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #sheetId)();
  IntColumn get rowIndex => integer()();
  BoolColumn get manuallyAdjusted => boolean()();

  @override
  Set<Column> get primaryKey => {sheetId, rowIndex};
}

@DataClassName('ColsManuallyAdjustedWidthEntity')
class ColsManuallyAdjustedWidthTable extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #sheetId)();
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

class SetCellPositionConverter
    extends TypeConverter<Set<CellPosition>, String> {
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
