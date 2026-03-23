// The Interface
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';

abstract class ILocalDataSource {
  Future<void> batchInsertOrUpdate(List<UpdateUnit> items);
}

// The Implementation
class DriftLocalDataSource implements ILocalDataSource {
  final AppDatabase db;

  DriftLocalDataSource();

  @override
  Future<void> batchInsertOrUpdate(List<UpdateUnit> items) async {
    // Write your Drift-specific batch insertion logic here
  }
}