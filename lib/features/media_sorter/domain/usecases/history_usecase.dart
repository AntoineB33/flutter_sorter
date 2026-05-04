import 'package:trying_flutter/features/media_sorter/domain/models/history_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';

class HistoryUsecase {
  final HistoryRepository historyRepository;

  HistoryUsecase(this.historyRepository);

  void moveInUpdateHistory(int sheetId, HistoryType historyType, int direction) {
    historyRepository.moveInUpdateHistory(sheetId, historyType, direction);
  }
}
