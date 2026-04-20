import 'package:trying_flutter/features/media_sorter/data/datasources/local_data_source.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';

class HistoryUsecase {
  final HistoryRepository historyRepository;
  final ILocalDataSource saveRepository;

  HistoryUsecase(this.historyRepository, this.saveRepository);

  List<SyncRequest> moveInUpdateHistory(int direction) {
    return historyRepository.moveInUpdateHistory(direction);
  }

  void stopEditing(bool escape) {
    saveRepository.save(historyRepository.stopEditing(escape));
  }
}
