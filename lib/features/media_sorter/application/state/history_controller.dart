import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/history_usecase.dart';

// --- Manager Class ---
class HistoryController extends ChangeNotifier {
  final HistoryUsecase historyUsecase;

  HistoryController(this.historyUsecase);

  void moveInUpdateHistory(int direction) {
    historyUsecase.moveInUpdateHistory(direction);
  }
  
  void commitHistory(UpdateData updateData) {
    historyUsecase.commitHistory(updateData);
  }

  void undo() {
    moveInUpdateHistory(-1);
  }

  void redo() {
    moveInUpdateHistory(1);
  }
}
