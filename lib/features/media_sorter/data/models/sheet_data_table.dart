import 'dart:math';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';
import 'package:drift/drift.dart';

class SheetDataTables extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  List<ColumnType> columnTypes;
  List<UpdateData> updateHistories;
  int historyIndex;
  List<double> rowsBottomPos;
  List<double> colRightPos;
  List<bool> rowsManuallyAdjustedHeight;
  List<bool> colsManuallyAdjustedWidth;
  double colHeaderHeight;
  double rowHeaderWidth;
  List<Point<int>> selectedCells;
  Point<int> primarySelectedCell;
  double scrollOffsetX;
  double scrollOffsetY;
  final List<int> bestSortFound;
  final List<int> cursors;
  final List<List<int>> possibleIntsById;
  final List<List<List<int>>> validAreasById;
  final List<int> bestDistFound;
  int sortIndex;
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

class SheetColumns extends Table {
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