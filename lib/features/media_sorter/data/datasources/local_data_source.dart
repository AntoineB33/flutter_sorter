// The Interface
abstract class ILocalDataSource {
  Future<void> batchInsertOrUpdate(List<MyEntity> items);
}

// The Implementation
class DriftLocalDataSource implements ILocalDataSource {
  final AppDatabase driftDb; // Your generated Drift database class

  DriftLocalDataSource(this.driftDb);

  @override
  Future<void> batchInsertOrUpdate(List<MyEntity> items) async {
    // Write your Drift-specific batch insertion logic here
  }
}