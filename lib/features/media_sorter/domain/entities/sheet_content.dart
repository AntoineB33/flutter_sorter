import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';

class SheetContent {
  final List<List<String>> table;
  List<ColumnType> columnTypes;

  SheetContent({
    required this.table,
    required this.columnTypes
  });
}