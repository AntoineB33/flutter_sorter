import 'dart:convert';

import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:drift/drift.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

class SheetDataTables extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get historyIndex => integer()();
  RealColumn get colHeaderHeight => real()();
  RealColumn get rowHeaderWidth => real()();
  IntColumn get primarySelectedCellX => integer()();
  IntColumn get primarySelectedCellY => integer()();
  RealColumn get scrollOffsetX => real()();
  RealColumn get scrollOffsetY => real()();
  IntColumn get sortIndex => integer()();
}

// Store the position-content map here
class SheetCells extends Table {
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

class SheetColumnTypes extends Table {
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

class UpdateUnitMapConverter extends TypeConverter<Map<Record, UpdateUnit>, String> {
  const UpdateUnitMapConverter();

  @override
  Map<Record, UpdateUnit> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as Map<String, dynamic>;
    return decoded.map((key, value) {
      return MapEntry(
        key,
        UpdateUnit.fromJson(value as Map<String, dynamic>),
      );
    });
  }

  @override
  String toSql(Map<Record, UpdateUnit> value) {
    final encoded = value.map((key, val) => MapEntry(key, val.toJson()));
    return jsonEncode(encoded);
  }
}

class UpdateHistories extends Table {
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get chronoId => integer()();
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  TextColumn get updates => text().map(const UpdateUnitMapConverter())();
}

class RowsBottomPos extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  IntColumn get rowIndex => integer()();
  RealColumn get bottomPos => real()();

  @override
  Set<Column> get primaryKey => {sheetId, rowIndex};
}

class ColRightPos extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  IntColumn get colIndex => integer()();
  RealColumn get rightPos => real()();

  @override
  Set<Column> get primaryKey => {sheetId, colIndex};
}

class RowsManuallyAdjustedHeight extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  IntColumn get rowIndex => integer()();
  BoolColumn get manuallyAdjusted => boolean()();

  @override
  Set<Column> get primaryKey => {sheetId, rowIndex};
}

class ColsManuallyAdjustedWidth extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  IntColumn get colIndex => integer()();
  BoolColumn get manuallyAdjusted => boolean()();

  @override
  Set<Column> get primaryKey => {sheetId, colIndex};
}

class SelectedCells extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  IntColumn get cellIndex => integer()(); // To allow multiple selected cells
  IntColumn get row => integer()();
  IntColumn get col => integer()();

  @override
  Set<Column> get primaryKey => {sheetId, cellIndex};
}

class BestSortFound extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  IntColumn get sortIndex => integer()();
  IntColumn get value => integer()();

  @override
  Set<Column> get primaryKey => {sheetId, sortIndex};
}

class Cursors extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  IntColumn get cursorIndex => integer()();
  IntColumn get value => integer()();

  @override
  Set<Column> get primaryKey => {sheetId, cursorIndex};
}

class PossibleIntsById extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  IntColumn get id => integer()();
  IntColumn get intIndex => integer()();
  IntColumn get value => integer()();

  @override
  Set<Column> get primaryKey => {sheetId, id, intIndex};
}

class ValidAreasById extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  IntColumn get id => integer()();
  IntColumn get intIndex => integer()();
  IntColumn get areaIndex => integer()();
  IntColumn get areaEdge => integer()();

  @override
  Set<Column> get primaryKey => {sheetId, id, intIndex, areaIndex};
}

class BestDistFound extends Table {
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  IntColumn get id => integer()();
  IntColumn get value => integer()();

  @override
  Set<Column> get primaryKey => {sheetId, id};
}

class AnalysisResults extends Table {
  // Excluded from JSON. Reconstituted in the constructor.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final NodeStruct errorRoot = NodeStruct(
    instruction: SpreadsheetConstants.errorMsg,
    hideIfEmpty: true,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  final NodeStruct warningRoot = NodeStruct(
    instruction: SpreadsheetConstants.warningMsg,
    hideIfEmpty: true,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  final NodeStruct categoriesRoot = NodeStruct(
    instruction: SpreadsheetConstants.categoryMsg,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  final NodeStruct distPairsRoot = NodeStruct(
    instruction: SpreadsheetConstants.distPairsMsg,
  );

  // Added as fields so json_serializable can automatically save/load them
  final List<NodeStruct> errorChildren;
  final List<NodeStruct> warningChildren;
  final List<NodeStruct> categoryChildren;
  final List<NodeStruct> distPairChildren;

  /// 2D table of attribute identifiers (row index or name)
  /// mentioned in each cell.
  List<List<Set<Attribute>>> tableToAtt;
  Map<String, Cell> names;
  Map<String, List<int>> attToCol;
  List<int> nameIndexes;
  List<List<StrInt>> formatedTable;

  /// Maps attribute identifiers (row index or name)
  /// to a map of pointers (row index) to the column index,
  /// in this direction so it is easy to diffuse characteristics to pointers.
  @JsonKey(fromJson: _attColMapFromJson, toJson: _attColMapToJson)
  Map<Attribute, Map<int, Cols>> attToRefFromAttColToCol;
  @JsonKey(fromJson: _depColMapFromJson, toJson: _depColMapToJson)
  Map<Attribute, Map<int, List<int>>> attToRefFromDepColToCol;
  Map<int, Set<Attribute>> colToAtt;
  List<bool> isMedium;
  List<int> validRowIndexes;
  List<int>? currentBestSort;

  List<List<int>> validAreas;
  Map<int, Map<int, List<SortingRule>>> myRules;
  List<List<int>> groupAttribution;
  List<List<int>> groupsToMaximize;

  bool validSortIsImpossible;
  bool isFindingBestSort;
  bool sortedWithValidSort;

  // true if the table is currently sorted with the current best sort found, false otherwise. If no valid sort is found, should be true.
  bool sortedWithCurrentBestSort;

  bool bestSortPossibleFound;
}

class SortStatusData extends Table {
  bool toApplyNextBestSort;
  bool toAlwaysApplyCurrentBestSort;
  bool analysisDone;
}
