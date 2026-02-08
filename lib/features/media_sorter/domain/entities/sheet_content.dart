import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';

class SheetContent {
  List<List<String>> table;
  List<ColumnType> columnTypes;

  SheetContent({
    required this.table,
    required this.columnTypes
  });
}