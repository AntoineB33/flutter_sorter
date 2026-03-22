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

  static String get historyIndexUpdateKey => 'historyIndex';
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

class UpdateUnitMapConverter extends TypeConverter<Map<String, UpdateUnit>, String> {
  const UpdateUnitMapConverter();

  @override
  Map<String, UpdateUnit> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as Map<String, dynamic>;
    return decoded.map((key, value) {
      return MapEntry(
        key,
        UpdateUnit.fromJson(value as Map<String, dynamic>),
      );
    });
  }

  @override
  String toSql(Map<String, UpdateUnit> value) {
    final encoded = value.map((key, val) => MapEntry(key, val.toJson()));
    return jsonEncode(encoded);
  }
}

class UpdateHistories extends Table {
  IntColumn get chronoId => integer().autoIncrement()(); // Primary key
  IntColumn get sheetId => integer().references(SheetDataTables, #id)();
  DateTimeColumn get timestamp => dateTime()();
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

