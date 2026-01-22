import 'dart:math';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';

// --- Models moved here ---
class CellUpdateHistory {
  Point<int> cell;
  String previousValue;
  String newValue;
  CellUpdateHistory({
    required this.cell,
    required this.previousValue,
    required this.newValue,
  });
}

class ColumnTypeUpdateHistory {
  int? colId;
  ColumnType? previousColumnType;
  ColumnType? newColumnType;
  ColumnTypeUpdateHistory({
    required this.colId,
    required this.previousColumnType,
    required this.newColumnType,
  });
}

class UpdateHistory {
  static const String updateCellContent = "updateCellContent";
  static const String updateColumnType = "updateColumnType";
  final String key;
  final DateTime timestamp;
  final List<CellUpdateHistory>? updatedCells = [];
  final List<ColumnTypeUpdateHistory>? updatedColumnTypes = [];
  UpdateHistory({required this.key, required this.timestamp});
}