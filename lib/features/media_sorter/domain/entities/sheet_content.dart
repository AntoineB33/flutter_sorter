import 'package:trying_flutter/features/media_sorter/core/utility/get_names.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';

class SheetContent {
  final List<List<String>> table;
  List<ColumnType> columnTypes;
  Set<int> sourceColIndices = {};

  SheetContent({
    required this.table,
    required this.columnTypes
  }) {
    for (int i = 0; i < columnTypes.length; i++) {
      if (GetNames.isSourceColumn(columnTypes[i])) {
        sourceColIndices.add(i);
      }
    }
  }
}