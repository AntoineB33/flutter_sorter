import 'dart:isolate';

import 'package:fpdart/fpdart.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';

class IsolateMessage {
  Either<TransferableTypedData, List<List<String>>> table;
  List<ColumnType> columnTypes;
  Set<int> sourceColIndices;
  IsolateMessage(this.table, this.columnTypes, this.sourceColIndices);
}