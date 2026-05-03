import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';

class HistoryUsecase {
  final HistoryRepository historyRepository;

  HistoryUsecase(this.historyRepository);

  void moveInUpdateHistory(HistoryType historyType, int direction) {
    historyRepository.moveInUpdateHistory(historyType, direction);
  }

  void commitHistory(bool sameHistIdFromLast) {
    historyRepository.commitHistory(sameHistIdFromLast);
  }
}
