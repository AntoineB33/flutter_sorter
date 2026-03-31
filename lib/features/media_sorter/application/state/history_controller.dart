import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/entities/update_data.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/history_usecase.dart';

// --- Manager Class ---
class HistoryController extends ChangeNotifier {
  final HistoryUsecase historyUsecase;

  HistoryController(this.historyUsecase);

  UpdateData? moveInUpdateHistory(int direction) {
    return historyUsecase.moveInUpdateHistory(direction);
  }

  void newPrimarySelection(int row, int col) {
    historyUsecase.newPrimarySelection(row, col);
  }
}
