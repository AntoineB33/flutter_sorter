import 'dart:isolate';
import 'package:trying_flutter/features/media_sorter/domain/entities/column_type.dart';

/// A sealed class to ensure type safety when sending messages to the Isolate.
sealed class IsolateMessage {
  final List<ColumnType> columnTypes;
  const IsolateMessage(this.columnTypes);
}

/// Use this for small datasets (direct list passing)
class RawDataMessage extends IsolateMessage {
  final List<List<String>> table;
  
  const RawDataMessage({
    required this.table, 
    required List<ColumnType> columnTypes
  }) : super(columnTypes);
}

/// Use this for large datasets (memory optimized)
class TransferableDataMessage extends IsolateMessage {
  final TransferableTypedData dataPackage;

  const TransferableDataMessage({
    required this.dataPackage, 
    required List<ColumnType> columnTypes
  }) : super(columnTypes);
}