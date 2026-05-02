import 'package:trying_flutter/features/media_sorter/data/datasources/local_data_source.dart';
import 'package:trying_flutter/features/media_sorter/data/store/current_change_list.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/sync_repository.dart';

class SyncRepositoryImpl extends SyncRepository {
  final ILocalDataSource localDataSource;
  final CurrentChangeList currentChangeList;

  SyncRepositoryImpl(this.localDataSource, this.currentChangeList);

  @override
  void save() {
    localDataSource.save(currentChangeList.changeListWithoutHist);
    currentChangeList.clear();
  }
}
