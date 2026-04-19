import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';

enum DataBaseOperationType { insert, update, delete }

abstract class ChangeSet {
  void merge(ChangeSet other);
  IMap<String, SyncRequest> toMap();
}

abstract class SyncRequest {
}