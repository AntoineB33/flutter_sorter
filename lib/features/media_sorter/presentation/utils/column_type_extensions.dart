import 'package:flutter/material.dart';
import '../../domain/entities/column_type.dart';

extension ColumnTypeX on ColumnType {
  Color get color {
    switch (this) {
      case ColumnType.names:
        return Colors.green;
      case ColumnType.dependencies:
        return Colors.red;
      case ColumnType.sprawl:
        return Colors.purple;
      case ColumnType.attributes:
        return Colors.orange;
      case ColumnType.filePath:
        return Colors.blue;
      case ColumnType.url:
        return Colors.cyan;
    }
  }
}