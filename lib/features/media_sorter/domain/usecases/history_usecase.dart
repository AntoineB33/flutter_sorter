import 'package:trying_flutter/features/media_sorter/domain/models/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/save_repository.dart';

class HistoryUsecase {
  final HistoryRepository historyRepository;
  final SaveRepository saveRepository;

  HistoryUsecase(this.historyRepository, this.saveRepository);

  UpdateData? moveInUpdateHistory(int direction) {
    return historyRepository.moveInUpdateHistory(direction);
  }

  void stopEditing(bool escape) {
    saveRepository.save(historyRepository.stopEditing(escape));
  }
}
