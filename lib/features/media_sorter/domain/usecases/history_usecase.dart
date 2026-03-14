import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';

class HistoryUsecase {
  final HistoryRepository historyRepository;

  HistoryUsecase(this.historyRepository);

  void moveInUpdateHistory(int direction) {
    historyRepository.moveInUpdateHistory(direction);
  }
  
  void stopEditing(String prevValue) {
    historyRepository.stopEditing(prevValue);
  }
}