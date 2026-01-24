import 'dart:collection';

import 'package:trying_flutter/features/media_sorter/domain/entities/attribute.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/sheet_content.dart';



class GetNames {
  static String getRowName(List<int> nameIndexes, List<List<HashSet<Attribute>>> tableToAtt, int row) {
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

  static String getColumnLabel(int col) {
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

  static String getAttName(List<int> nameIndexes, List<List<HashSet<Attribute>>> tableToAtt, Attribute att) {
    if (att.isRow()) {
      return getRowName(nameIndexes, tableToAtt, att.rowId!);
    } else {
      return "${getColumnLabel(att.colId!)}.${att.name}";
    }
  }

  static ColumnType getColumnType(SheetContent sheetContent, int col) {
    if (col >= sheetContent.columnTypes.length) return ColumnType.attributes;
    return sheetContent.columnTypes[col];
  }

  static bool isSourceColumn(ColumnType type) {
    return type == ColumnType.urls || type == ColumnType.filePath;
  }
}