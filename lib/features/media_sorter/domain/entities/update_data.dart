import 'dart:math';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';

sealed class UpdateData {}

class SheetNameUpdate extends UpdateData {
  final String newName;
  final String? previousName;
  SheetNameUpdate({required this.newName, this.previousName});
}

class CellUpdate extends UpdateData {
  int rowId;
  int colId;
  Point<int> cell;
  String previousValue;
  String newValue;
  CellUpdate({
    required this.rowId, required this.colId,
    required this.newValue,
    this.previousValue = "",
  }) : cell = Point<int>(rowId, colId);
}

class ColumnTypeUpdate extends UpdateData {
  int colId;
  ColumnType newColumnType;
  ColumnType? previousColumnType;
  ColumnTypeUpdate({
    required this.colId,
    required this.newColumnType,
    this.previousColumnType,
  });
}
