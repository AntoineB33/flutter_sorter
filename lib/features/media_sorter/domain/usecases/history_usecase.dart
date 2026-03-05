import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/repositories/history_repository.dart';

class HistoryUsecase {
  final HistoryRepository historyRepository;
  
  Stream<UpdateRequest> get updateDataStream => historyRepository.updateDataStream;

  HistoryUsecase(this.historyRepository);

  void moveInUpdateHistory(int direction) {
    historyRepository.moveInUpdateHistory(direction);
  }

  void commitHistory(UpdateData updateData) {
    historyRepository.commitHistory(updateData);
  }
}