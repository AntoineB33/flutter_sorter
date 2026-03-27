import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';

class HistoryUsecase {
  final HistoryRepository historyRepository;

  HistoryUsecase(this.historyRepository);

  UpdateData? moveInUpdateHistory(int direction) {
    return historyRepository.moveInUpdateHistory(direction);
  }
  
  void stopEditing(bool escape, {Map<Record, UpdateUnit>? updates}) {
    historyRepository.stopEditing(escape, updates: updates);
  }
}