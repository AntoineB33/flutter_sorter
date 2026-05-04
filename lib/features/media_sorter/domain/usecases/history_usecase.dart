import 'package:trying_flutter/features/media_sorter/domain/models/history_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';

class HistoryUsecase {
  final HistoryRepository historyRepository;

  HistoryUsecase(this.historyRepository);

  bool moveInUpdateHistory(int sheetId, HistoryType historyType, int direction) {
    return historyRepository.moveInUpdateHistory(sheetId, historyType, direction);
  }
}
