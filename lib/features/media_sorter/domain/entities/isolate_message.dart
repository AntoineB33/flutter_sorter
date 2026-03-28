import 'dart:isolate';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';

class IsolateMessage {
  Either<TransferableTypedData, Map<(int rowId, int colId), String>> table;
  Map<int, ColumnType> columnTypes;
  IsolateMessage(this.table, this.columnTypes);
}