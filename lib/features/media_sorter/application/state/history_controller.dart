import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/change_set.dart';
import 'package:trying_flutter/features/media_sorter/domain/usecases/history_usecase.dart';

// --- Manager Class ---
class HistoryController extends ChangeNotifier {
  final HistoryUsecase historyUsecase;

  HistoryController(this.historyUsecase);

  @useResult
  ChangeSet moveInUpdateHistory(int direction) {
    return historyUsecase.moveInUpdateHistory(direction);
  }
}
