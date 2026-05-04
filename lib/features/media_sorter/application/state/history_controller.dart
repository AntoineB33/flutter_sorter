import 'package:flutter/material.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/history_type.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/history_usecase.dart';

// --- Manager Class ---
class HistoryController extends ChangeNotifier {
  final HistoryUsecase historyUsecase;

  HistoryController(this.historyUsecase);

  
  bool moveInUpdateHistory(int sheetId, HistoryType historyType, int direction) {
    return historyUsecase.moveInUpdateHistory(sheetId, historyType, direction);
  }
}
