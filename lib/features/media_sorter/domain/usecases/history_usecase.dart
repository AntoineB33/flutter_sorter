import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';

class HistoryUsecase {
  final HistoryRepository historyRepository;

  HistoryUsecase(this.historyRepository);

  UpdateData? moveInUpdateHistory(int direction) {
    return historyRepository.moveInUpdateHistory(direction);
  }
  
  void stopEditing(Map<String, UpdateUnit> updates, bool escape) {
    historyRepository.stopEditing(updates, escape);
  }
}