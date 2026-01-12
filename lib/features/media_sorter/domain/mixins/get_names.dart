import 'dart:collection';
import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';

mixin GetNames {
  List<int> get nameIndexes;
  List<List<HashSet<Attribute>>> get tableToAtt;
  List<ColumnType> get columnTypes;
  int get colCount;

  String getRowName(row) {
    List<String> rowNames = [];
    for (final index in nameIndexes) {
      for (final name in tableToAtt[row][index]) {
        if (name.name != null) {
          rowNames.add(name.name!);
        }
      }
    }
    return 'Row $row: ${rowNames.join(', ')}';
  }

  String getColumnLabel(int col) {
    String columnLabel = "";
    int tempCol = col + 1; // Excel columns start at 1, not 0

    // Convert column number to letters (e.g., 1 -> A, 27 -> AA)
    while (tempCol > 0) {
      int remainder = (tempCol - 1) % 26;
      columnLabel = String.fromCharCode(65 + remainder) + columnLabel;
      tempCol = (tempCol - 1) ~/ 26;
    }

    return columnLabel;
  }

  String getAttName(Attribute att) {
    if (att.isRow()) {
      return getRowName(att.rowId!);
    } else {
      return "${getColumnLabel(att.colId!)}.${att.name}";
    }
  }

  ColumnType getColumnType(int col) {
    if (col >= columnTypes.length) return ColumnType.attributes;
    return columnTypes[col];
  }
}